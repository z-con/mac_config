return {
    {
        "folke/noice.nvim",
        opts = {
            routes = {
                { filter = { event = "notify", find = "No information available" }, opts = { skip = true } },
            },
        },
    },
    { "folke/lazy.nvim", opts = { checker = { notify = false } } },
}
