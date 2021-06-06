-- a Client is used to connect this app to a Place. arg[2] is the URL of the place to
-- connect to, which Assist sets up for you.
local client = Client(
    arg[2], 
    "allo-todo"
)

-- App manages the Client connection for you, and manages the lifetime of the
-- your app.
local app = App(client)



-- Assets are files (images, glb models, videos, sounds, etc...) that you want to use
-- in your app. They need to be published so that user's headsets can download them
-- before you can use them. We make `assets` global so you can use it throughout your app.
assets = {
    quit = ui.Asset.File("images/quit.png"),
    checkmark = ui.Asset.File("images/checkmark.png"),
}
app.assetManager:add(assets)




class.TodosView(ui.Surface)
function TodosView:_init(bounds)
    self:super(bounds)
    self.grabbable = true

    self.quitButton = self:addSubview(ui.Button(ui.Bounds{
        size=ui.Size(0.12,0.12,0.05)
    }))
    self.quitButton:setDefaultTexture(assets.quit)
    self.quitButton.onActivated = function()
        app:quit()
    end

    self.addButton = self:addSubview(ui.Button(ui.Bounds{
        size=ui.Size(bounds.size.width*0.8,0.1,0.05)
    }))
    self.addButton.label:setText("Add todo")
    self.addButton.onActivated = function(hand)
        self:showNewTodoPopup(hand)
    end

    self.todoViews = {}
    self:layout()
end



function TodosView:layout()
    local height = #self.todoViews * 0.13 + 0.25

    local pen = ui.Bounds{
        size=self.addButton.bounds.size:copy(),
        pose=ui.Pose(0, -height/2, self.addButton.bounds.size.depth/2)
    }
    pen:move(0, 0.07, 0)
    self.addButton:setBounds(pen:copy())
    pen:move(0, 0.15, 0)
    for i, v in ipairs(self.todoViews) do
        v:setBounds(pen:copy())
        pen:move(0, 0.13, 0)
    end

    self.quitButton.bounds:moveToOrigin():move( 0.52, height/2, 0.025)
    self.quitButton:setBounds()

    self.bounds.size.height = height
    self:setBounds()
end




function TodosView:showNewTodoPopup(hand)
    local popup = ui.Surface(ui.Bounds{size=ui.Size(1,0.5,0.05)})

    local input = popup:addSubview(ui.TextField{
        bounds = ui.Bounds{size=ui.Size(0.8,0.1,0.05)}:move(0, 0.15, 0.025)
    })
    local done = function()
        self:addTodo(input.label.text)
        popup:removeFromSuperview()
    end
    input.onReturn = function()
        done()
        return false
    end
    input:askToFocus(hand)

    local addButton = popup:addSubview(ui.Button(ui.Bounds{size=ui.Size(popup.bounds.size.width*0.8,0.1,0.05)}))
    addButton.bounds:move(0, 0, 0.025)
    addButton.label:setText("Add")
    addButton.onActivated = done

    local cancelButton = popup:addSubview(ui.Button(ui.Bounds{size=ui.Size(popup.bounds.size.width*0.8,0.1,0.05)}))
    cancelButton:setColor({0.4, 0.4, 0.3, 1.0})
    cancelButton.bounds:move(0, -0.15, 0.025)
    cancelButton.label:setText("Cancel")
    cancelButton.onActivated = function()
        popup:removeFromSuperview()
    end

    app:openPopupNearHand(popup, hand)
end

function TodosView:addTodo(text)
    local todoView = ui.View(ui.Bounds{size=ui.Size(self.bounds.size.width*0.8,0.1,0.05)})

    local checkButton = todoView:addSubview(ui.Button(ui.Bounds{size=ui.Size(0.1, 0.1, 0.05)}))
    checkButton.bounds:move(-self.bounds.size.width/2 + checkButton.bounds.size.width, 0, 0)
    checkButton:setDefaultTexture(assets.checkmark)
    checkButton.onActivated = function()
        self:removeTodo(todoView)
    end

    local label = todoView:addSubview(ui.Label{
        bounds= todoView.bounds:copy():inset(0.1, 0.05, 0):move(0.05, 0,0),
        color= {0,0,0, 1},
        halign= "left",
        text= text
    })

    table.insert(self.todoViews, todoView)
    self:layout()
    self:addSubview(todoView)
end

function TodosView:removeTodo(todoView)
    local index = tablex.find(self.todoViews, todoView)
    table.remove(self.todoViews, index)
    todoView:removeFromSuperview()
    self:layout()
end



-- Connect to the designated remote Place server
app:connect()
-- hand over runtime to the app! App will now run forever,
-- or until the app is shut down (ctrl-C or exit button pressed).
app:run()

-- hand over runtime to the app! App will now run forever,
-- or until the app is shut down (ctrl-C or exit button pressed).
app:run()
