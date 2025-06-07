# Dartboard.nvim

A Neovim plugin to mark files and quickly access them, inspired by Harpoon and Lasso.

## Features

- Tag files to a list for quick access
- View tagged files in Telescope
- Open files by index (1-9)
- Remove files from the list
- Clear the entire list
- Persistent storage of tagged files on a per-project basis

## Requirements

- Neovim >= 0.7.0
- Telescope.nvim

## Installation

### Using packer.nvim
```lua
use {
  'markgandolfo/dartboard.nvim',
  requires = {'nvim-telescope/telescope.nvim'}
}
```

### Using lazy.nvim
```lua
{
  'markgandolfo/dartboard.nvim',
  dependencies = {'nvim-telescope/telescope.nvim'}
}
```

## Setup

```lua
require('dartboard').setup({
  -- use_default_keymaps = false,
})
```

## Default Keybindings

The plugin provides the following default keybindings:

- `<leader>da` - Add current file to marks
- `<leader>dr` - Remove current file from marks
- `<leader>dl` - List marked files in Telescope
- `<leader>dc` - Clear all marks
- `<leader>1` through `<leader>9` - Go to mark by index

You can disable these default keybindings by setting `use_default_keymaps = false` in the setup.

## Telescope Integration

When viewing your marked files with `:DartboardList`:
- Press `Enter` to open the selected file
- Press `Ctrl-v` to open in vertical split
- Press `Ctrl-x` to open in horizontal split
- Press `Ctrl-d` to remove the selected file from the list
- Press `Ctrl-k` to move the selected file up in the list
- Press `Ctrl-j` to move the selected file down in the list

## Usage

### Commands

- `:DartboardAdd` - Add current file to marks
- `:DartboardRemove` - Remove current file from marks
- `:DartboardClear` - Clear all marks
- `:DartboardList` - List marks in Telescope
- `:DartboardGoto1` to `:DartboardGoto9` - Go to mark by index

### Recommended Keymaps

```lua
-- Add current file to marks
vim.keymap.set('n', '<leader>da', ':DartboardAdd<CR>', { desc = '[M]ark [A]dd file' })

-- Remove current file from marks
vim.keymap.set('n', '<leader>dr', ':DartboardRemove<CR>', { desc = '[M]ark [R]emove file' })

-- Show marked files in Telescope
vim.keymap.set('n', '<leader>dl', ':DartboardList<CR>', { desc = '[M]ark [S]how files' })

-- Clear all marks
vim.keymap.set('n', '<leader>dc', ':DartboardClear<CR>', { desc = '[M]ark [C]lear all' })

-- Quick navigation to marks by index
vim.keymap.set('n', '<leader>1', ':DartboardGoto1<CR>', { desc = 'Go to mark 1' })
vim.keymap.set('n', '<leader>2', ':DartboardGoto2<CR>', { desc = 'Go to mark 2' })
vim.keymap.set('n', '<leader>3', ':DartboardGoto3<CR>', { desc = 'Go to mark 3' })
vim.keymap.set('n', '<leader>4', ':DartboardGoto4<CR>', { desc = 'Go to mark 4' })
vim.keymap.set('n', '<leader>5', ':DartboardGoto5<CR>', { desc = 'Go to mark 5' })
...
vim.keymap.set('n', '<leader>9', ':DartboardGoto9<CR>', { desc = 'Go to mark 9' })
```


## FAQs

### How do I remove whichkey from seeing the <leader># keymaps?

To prevent which-key from displaying the `<leader>#` keymaps, you can set the `which_key` option to `false` for those specific keybindings.
For example, in lazy.nvim, you can modify the keymap setup like this:

```lua
return {
  {
    'markgandolfo/dartboard.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    config = function()
      require('dartboard').setup {
        -- Your configuration options here
      }

      require('which-key').add {
        { '<leader>1', hidden = true },
        { '<leader>2', hidden = true },
        { '<leader>3', hidden = true },
        { '<leader>4', hidden = true },
        { '<leader>5', hidden = true },
        { '<leader>6', hidden = true },
        { '<leader>7', hidden = true },
        { '<leader>8', hidden = true },
        { '<leader>9', hidden = true },
      }
    end,
  },
}
```

## License

MI
