return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")
    -- local utils = require("utils")
    _Gopts = {
      position = "center",
      hl = "Type",
      wrap = "overflow",
    }

    local function get_all_files_in_dir(dir)
      local files = {}
      local scan = vim.fn.globpath(dir, "**/*.lua", true, true)
      for _, file in ipairs(scan) do
        table.insert(files, file)
      end
      return files
    end

    local function load_random_header()
      math.randomseed(os.time())
      local header_folder = "D:/nvim_config/nvim/lua/plugins/header_img/"
      local files = get_all_files_in_dir(header_folder)

      if #files == 0 then
        return nil
      end

      local random_file = files[math.random(#files)]
      -- vim.notify(random_file)
      local relative_path = random_file:sub(#header_folder + 1)
      local module_name = "plugins.header_img." .. relative_path:gsub("/", "."):gsub("\\", "."):gsub("%.lua$", "")

      package.loaded[module_name] = nil

      local ok, module = pcall(require, module_name)
      if ok and module then
        -- vim.notify(module)
        return module
      else
        return nil
      end
    end

    local function change_header()
      local new_header = load_random_header()
      if new_header then
        dashboard.config.layout[2] = new_header
        vim.cmd("AlphaRedraw")
      else
        print("No images inside header_img folder.")
      end
    end

    local header = load_random_header()
    if header then
      dashboard.config.layout[2] = header
    else
      print("No images inside header_img folder.")
    end

    -- dashboard.section.tasks = {
    --   type = "text",
    --   val = utils.get_today_tasks(),
    --   opts = {
    --     position = "center",
    --     hl = "Comment",
    --     width = 50,
    --   },
    -- }
    --
    dashboard.section.buttons.val = {
      dashboard.button("f", " " .. " Find file",       "<cmd> lua LazyVim.pick()() <cr>"),
      dashboard.button("n", " " .. " New file",        [[<cmd> ene <BAR> startinsert <cr>]]),
      dashboard.button("r", " " .. " Recent files",    [[<cmd> lua LazyVim.pick("oldfiles")() <cr>]]),
      dashboard.button("g", " " .. " Find text",       [[<cmd> lua LazyVim.pick("live_grep")() <cr>]]),
      dashboard.button("c", " " .. " Config",          "<cmd> lua LazyVim.pick.config_files()() <cr>"),
      dashboard.button("s", " " .. " Restore Session", [[<cmd> lua require("persistence").load() <cr>]]),
      dashboard.button("x", " " .. " Lazy Extras",     "<cmd> LazyExtras <cr>"),
      dashboard.button("l", "󰒲 " .. " Lazy",            "<cmd> Lazy <cr>"),
      dashboard.button("q", " " .. " Quit",            "<cmd> qa <cr>"),
    }

    dashboard.config.layout = {
      { type = "padding", val = 3 },
      header,
      { type = "padding", val = 2 },
      {
        type = "group",
        val = {
          -- {
          --   type = "group",
          --   val = {
          --     {
          --       type = "text",
          --       val = "📅 Tasks for today",
          --       opts = { hl = "Keyword", position = "center" },
          --     },
          --     dashboard.section.tasks,
          --   },
          --   opts = { spacing = 1 },
          -- },
          {
            type = "group",
            val = dashboard.section.buttons.val,
            opts = { spacing = 1 },
          },
        },
        opts = {
          layout = "horizontal",
        },
      },
      -- { type = "padding", val = 2 },
      dashboard.section.footer,
    }
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyVimStarted",
      desc = "Add Alpha dashboard footer",
      once = true,
      callback = function()
        local stats = require("lazy").stats()
        local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
        dashboard.section.footer.val =
          { " ", " ", " ", " Loaded " .. stats.count .. " plugins  in " .. ms .. " ms " }
        dashboard.section.header.opts.hl = "DashboardFooter"
        pcall(vim.cmd.AlphaRedraw)
      end,
    })

    dashboard.opts.opts.noautocmd = true
    alpha.setup(dashboard.opts)
  end,
}
