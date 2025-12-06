const filter = {
  url: [
    {
      urlMatches: ".wikipedia.org|.wikiquote.org|.wiktionary.org",
      // urlMatches: ".wikipedia.org",
    },
  ],
};

chrome.runtime.onInstalled.addListener((details) => {
  chrome.contextMenus.create({
    title: "Search in Wikiwand",
    contexts: ["selection"],
    id: "searchInWikiwand",
  });

  if (details.reason == "install") {
    chrome.tabs.create({ url: "https://www.wikiwand.com?extension=installed" });

    // uninstall form
    chrome.runtime.setUninstallURL("https://forms.gle/5TMJSzNEJLJrgXRE7");
  }

  if (details.reason == "update") {
    chrome.tabs.create({ url: "https://www.wikiwand.com?extension=update" });
  }
});

chrome.runtime.onMessageExternal.addListener(function (
  request,
  sender,
  sendResponse
) {
  if (request) {
    // console.log("request: ", request);
    if (request.message) {
      // console.log("request.message: ", request.message);
      if (request.message == "isInstalled") {
        sendResponse({ isInstalled: true });
      }
    }
  }
  return true;
});

const bucketMap = {
  wikipedia: "articles",
  wikiquote: "quotes",
  wiktionary: "dictionary",
};

chrome.webNavigation.onBeforeNavigate.addListener((details) => {
  if (!details.url) return;

  let url = new URL(details.url);
  // catch Google redirects:
  if (
    url?.host === "www.google.com" &&
    url?.searchParams?.get("url") &&
    url?.pathname === "/url"
  ) {
    url = new URL(url?.searchParams?.get("url"));
  }

  const hostParts = url?.hostname.split(".");
  const oldFormat = url?.searchParams?.get("oldformat");
  const bucket = hostParts?.length && bucketMap[hostParts[1]];

  if (
    !bucket ||
    oldFormat ||
    hostParts?.length !== 3 ||
    (!url?.pathname.startsWith("/wiki/") && !url?.pathname.startsWith("/zh"))
  )
    return;

  const lang = url.pathname.startsWith("/zh")
    ? url.pathname.split("/")[1]
    : hostParts[0]?.replace("www", "") || "en";
  const title = url.pathname.split("/").slice(2)?.join("/") || "Main_Page";

  // console.info("Wikipedia page!!", url, `https://www.wikiwand.com${lang ? `/${lang}` : ""}${title ? `/${bucket}/${title}` : ""}`);

  if (
    title.includes(":") &&
    !title.split(":")?.some((a) => a.startsWith("_"))
  ) {
    return;
  }

  chrome.tabs.update(details.tabId, {
    url: `https://www.wikiwand.com${lang ? `/${lang}` : ""}${
      title ? `/${bucket}/${title}` : ""
    }`,
  });
}, filter);

// icon click
chrome.action.onClicked.addListener(function () {
  chrome.tabs.create({ url: "https://www.wikiwand.com" });
});

// context menu onclick:
chrome.contextMenus.onClicked.addListener(getSelection);

async function getSelection({ selectionText, menuItemId }, tab) {
  // console.log("getSelection: ", selectionText);

  if (menuItemId === "searchInWikiwand") {
    const lang = navigator?.language?.split("-")[0] || "en";
    // console.log("language: ", lang);

    const url = new URL(`https://www.wikiwand.com/${lang}/search`);
    url.searchParams.append("q", selectionText);

    chrome.tabs.create({ url: url.toString() });
  }
}
