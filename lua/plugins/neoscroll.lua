return {
  "karb94/neoscroll.nvim",
  opts = {
	  mappings = {                 -- Keys to be mapped to their corresponding default scrolling animation
	    '<C-u>', '<C-d>',
	    '<C-b>', '<C-f>',
	    '<C-y>', '<C-e>',
	    'zt', 'zz', 'zb',
	  },
	  duration_multiplier = 0.4,   -- Global duration multiplier
	  easing = 'linear',           -- Default easing function
	  ignored_events = {           -- Events ignored while scrolling
	      'WinScrolled', 'CursorMoved'
	  },
	},
}
