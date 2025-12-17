source /usr/share/cachyos-fish-config/cachyos-config.fish

if status is-interactive

	fastfetch
	starship init fish | source
end

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
