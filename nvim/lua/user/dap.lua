local dap = require("dap")

require("dap-vscode-js").setup({
    node_path = "/home/duzinho039/.nvm/versions/node/v19.7.0/bin/node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
    --[[ debugger_path = "(runtimedir)/site/pack/packer/opt/vscode-js-debug", -- Path to vscode-js-debug installation. ]]
    -- debugger_cmd = { "extension" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
    adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost'}, -- which adapters to register in nvim-dap
    -- log_file_path = "(stdpath cache)/dap_vscode_js.log" -- Path for file logging
    -- log_file_level = false -- Logging level for output to file. Set to false to disable file logging.
    -- log_console_level = vim.log.levels.ERROR -- Logging level for output to console. Set to false to disable console output.
})

local js_based_languages = { "typescript", "javascript", "typescriptreact" }

require("dap-go").setup{}

for _, language in ipairs(js_based_languages) do
    require("dap").configurations[language] = {


        {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
        },


        {
            type = "pwa-node",
            request = "attach",
            name = "Attach",
            processId = require 'dap.utils'.pick_process,
            cwd = "${workspaceFolder}",
        },


        {
            type = "pwa-chrome",
            request = "launch",
            name = "Start Chrome with \"localhost\"",
            url = "http://localhost:3000",
            webRoot = "${workspaceFolder}",
            userDataDir = "${workspaceFolder}/.vscode/vscode-chrome-debug-userdatadir"
        },


        {
            type = "pwa-node",
            request = "launch",
            name = "Debug Mocha Tests",
            program = "${file}",
            -- trace = true, -- include debugger info
            runtimeExecutable = "node",
            runtimeArgs = {
                "./node_modules/mocha/bin/mocha",
            },
            rootPath = "${workspaceFolder}",
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
            internalConsoleOptions = "neverOpen",
        },


        {
            type = "pwa-node",
            request = "launch",
            name = "Debug Jest Tests",
            -- trace = true, -- include debugger info
            runtimeExecutable = "node",
            runtimeArgs = {
                "./node_modules/jest/bin/jest.js",
                "--runInBand",
            },
            rootPath = "${workspaceFolder}",
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
            internalConsoleOptions = "neverOpen",
            resolveSourceMapLocations = {
                "${workspaceFolder}/**",
                "!**/node_modules/**",
            },
        },

        {
        }
    }
end


require("dap").configurations["go"] = {
    -- Bazel Remote Debugging (DAP) - Recommended for Bazel projects
    -- Start debug server with: bazel debug //path/to:target
    -- For function calls without optimization: bazel debug //path/to:target --@io_bazel_rules_go//go/config:gc_goopts="-N,-l"
    {
        type = "go",
        name = "Connect to Bazel Debug Server [DAP]",
        request = "attach",
        mode = "remote",
        port = 2345,
        host = "127.0.0.1",
        substitutePath = {
            {
                from = vim.fn.expand("${env:WORKSPACE_ROOT}/src") or "${workspaceFolder}/src",
                to = "src",
            },
            {
                from = vim.fn.expand("${env:WORKSPACE_ROOT}/bazel-go-code/external/") or "${workspaceFolder}/bazel-go-code/external/",
                to = "external/",
            },
            {
                from = vim.fn.expand("${env:WORKSPACE_ROOT}/bazel-out/") or "${workspaceFolder}/bazel-out/",
                to = "bazel-out/",
            },
            {
                from = vim.fn.expand("${env:WORKSPACE_ROOT}/bazel-go-code/external/go_sdk") or "${workspaceFolder}/bazel-go-code/external/go_sdk",
                to = "GOROOT/",
            },
        },
    },
    {
        type = "go",
        name = "Debug Current File",
        request = "launch",
        program = "${file}",
        dlvToolPath = vim.fn.exepath("dlv"),
    },
    {
        type = "go",
        name = "Debug Package",
        request = "launch",
        program = "${fileDirname}",
        dlvToolPath = vim.fn.exepath("dlv"),
    },
    {
        type = "go",
        name = "Debug Main Package",
        request = "launch",
        program = "${workspaceFolder}",
        dlvToolPath = vim.fn.exepath("dlv"),
    },
    {
        type = "go",
        name = "Attach to Process",
        mode = "local",
        request = "attach",
        processId = require("dap.utils").pick_process,
        dlvToolPath = vim.fn.exepath("dlv"),
    },
    {
        type = "go",
        name = "Attach to Remote",
        mode = "remote",
        request = "attach",
        substitutePath = {
            {
                from = "${workspaceFolder}",
                to = "/app",
            },
        },
        port = function()
            return vim.fn.input("Delve Port: ", "2345")
        end,
        host = function()
            return vim.fn.input("Host: ", "127.0.0.1")
        end,
        dlvToolPath = vim.fn.exepath("dlv"),
    },
    {
        type = "go",
        name = "Debug Test (Current File)",
        request = "launch",
        mode = "test",
        program = "${file}",
        dlvToolPath = vim.fn.exepath("dlv"),
    },
    {
        type = "go",
        name = "Debug Test (Package)",
        request = "launch",
        mode = "test",
        program = "${fileDirname}",
        dlvToolPath = vim.fn.exepath("dlv"),
    },
    {
        type = "go",
        name = "Debug Test (Specific)",
        request = "launch",
        mode = "test",
        program = "${fileDirname}",
        args = function()
            local test_name = vim.fn.input("Test name (e.g., TestMyFunction): ")
            if test_name == "" then
                return {}
            end
            return {"-test.run", "^" .. test_name .. "$"}
        end,
        dlvToolPath = vim.fn.exepath("dlv"),
    },
    {
        type = "go",
        name = "Debug with Arguments",
        request = "launch",
        program = "${file}",
        args = function()
            local args_string = vim.fn.input("Arguments: ")
            return vim.split(args_string, " ")
        end,
        dlvToolPath = vim.fn.exepath("dlv"),
    },
}


require("nvim-dap-virtual-text").setup()

require("dapui").setup()

local dap, dapui = require("dap"), require("dapui")

dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open({})
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close({})
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close({})
end

require('maximize').setup({
    plugins = {
        dapui = { enable = true },  -- enable nvim-dap-ui integration
        tree = { enable = true },   -- enable nvim-tree.lua integration
    }
})
