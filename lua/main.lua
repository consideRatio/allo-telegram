-- a Client is used to connect this app to a Place. arg[2] is the URL of the place to
-- connect to, which Assist sets up for you.
local client = Client(arg[2], "allo-telegram")

-- App manages the Client connection for you, and manages the lifetime of the
-- your app.
local app = App(client)

-- Assets are files (images, glb models, videos, sounds, etc...) that you want to use
-- in your app. They need to be published so that user's headsets can download them
-- before you can use them. We make `assets` global so you can use it throughout your app.
initial_assets = {
    quit = ui.Asset.File("assets/images/quit.png"),
    checkmark = ui.Asset.File("assets/images/checkmark.png"),
    sound = ui.Asset.File("assets/sounds/pushing_my_buttons.ogg"),
}
app.assetManager:add(initial_assets)

class.TelegramView(ui.Surface)
function TelegramView:_init(bounds)
    self:super(bounds)
    self.grabbable = true

    self.quitButton = self:addSubview(ui.Button(ui.Bounds {
        size = ui.Size(0.12, 0.12, 0.05),
    }))
    self.quitButton:setDefaultTexture(initial_assets.quit)
    self.quitButton.onActivated = function() app:quit() end

    self.playButton = self:addSubview(ui.Button(ui.Bounds {
        size = ui.Size(bounds.size.width * 0.8, 0.1, 0.05),
    }))
    self.playButton.label:setText("Play sound asset")
    self.playButton.onActivated = function(byEntity)
        self:mainButtonInteraction(byEntity)
    end

    self:layout()
end

function TelegramView:layout()
    local height = 0.13 + 0.25

    local pen = ui.Bounds {
        size = self.playButton.bounds.size:copy(),
        pose = ui.Pose(0, -height / 2, self.playButton.bounds.size.depth / 2),
    }
    pen:move(0, 0.07, 0)
    self.playButton:setBounds(pen:copy())

    self.quitButton.bounds:moveToOrigin():move(0.52, height / 2, 0.025)
    self.quitButton:setBounds()

    self.bounds.size.height = height
    self:setBounds()
end

function TelegramView:mainButtonInteraction(byEntity)
    self:playSound(initial_assets.sound)
end

app.mainView = TelegramView(ui.Bounds(0, 1.2, -2, 1, 0.5, 0.01))

-- Connect to the designated remote Place server
app:connect()

-- hand over runtime to the app! App will now run forever,
-- or until the app is shut down (ctrl-C or exit button pressed).
app:run()

-- hand over runtime to the app! App will now run forever,
-- or until the app is shut down (ctrl-C or exit button pressed).
app:run()
