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
    -- Asset ref: https://github.com/alloverse/alloui-lua/blob/main/lua/alloui/asset/asset.lua
    quit = ui.Asset.File("assets/images/quit.png"),
    checkmark = ui.Asset.File("assets/images/checkmark.png"),
    sound = ui.Asset.File("assets/sounds/pushing_my_buttons.ogg"),
}
-- assetManager ref: https://github.com/alloverse/alloui-lua/blob/main/lua/alloui/asset/asset_manager.lua
app.assetManager:add(initial_assets)

-- Surface ref: https://github.com/alloverse/alloui-lua/blob/main/lua/alloui/views/surface.lua
-- View ref: https://github.com/alloverse/alloui-lua/blob/main/lua/alloui/views/view.lua
class.TelegramView(ui.Surface)
function TelegramView:_init(bounds)
    self:super(bounds)
    self.grabbable = true

    -- Quit button
    self.quitButton = self:addSubview(ui.Button(ui.Bounds {
        size = ui.Size(0.12, 0.12, 0.05),
    }))
    self.quitButton:setDefaultTexture(initial_assets.quit)
    self.quitButton.onActivated = function() app:quit() end

    -- Interaction button
    self.mainButton = self:addSubview(ui.Button(ui.Bounds {
        size = ui.Size(bounds.size.width * 0.8, 0.1, 0.05),
    }))
    self.mainButton.label:setText("Try TTS")
    self.mainButton.onActivated = function(hand) self:showNewPopup(hand) end

    self:layout()
end

function TelegramView:layout()
    local height = 0.5

    local pen = ui.Bounds {
        size = self.mainButton.bounds.size:copy(),
        pose = ui.Pose(0, -height / 2, self.mainButton.bounds.size.depth / 2),
    }
    pen:move(0, height - self.mainButton.bounds.size.height, 0)
    self.mainButton:setBounds(pen:copy())

    self.quitButton.bounds:moveToOrigin():move(0.52, height / 2, 0.025)
    self.quitButton:setBounds()

    self.bounds.size.height = height
    self:setBounds()
end

function TelegramView:showNewPopup(hand)
    local popup = TelegramPopupView(ui.Bounds {size = ui.Size(1, 0.5, 0.05)},
                                    hand)

    app:openPopupNearHand(popup, hand)
end

class.TelegramPopupView(ui.Surface)
function TelegramPopupView:_init(bounds, hand)
    self:super(bounds)
    self.grabbable = true

    -- Interaction logic
    self.process = function()
        -- FIXME: This blocks the main thread, and the app is disconnected by
        --        alloplace.
        os.execute(
            "rm -f generated_sounds/output.wav generated_sounds/output.ogg")
        os.execute("tts --text '" .. self.input.label.text ..
                       "' --out_path generated_sounds/output.wav")
        os.execute(
            "ffmpeg -i generated_sounds/output.wav -acodec libvorbis generated_sounds/output.ogg")
    end

    self.preview = function()
        new_assets = {new = ui.Asset.File("generated_sounds/output.ogg")}
        app.assetManager:add(new_assets)
        self:playSound(new_assets.new)
    end

    -- Input textfield
    self.input = self:addSubview(ui.TextField(ui.Bounds {
        size = ui.Size(self.bounds.size.width * 0.8, 0.1, 0.05),
    }))
    self.input.onReturn = function()
        process()
        return false
    end
    self.input:askToFocus(hand)

    -- Process button
    self.processButton = self:addSubview(
                             ui.Button(ui.Bounds {
            size = ui.Size(self.bounds.size.width * 0.8, 0.1, 0.05),
        }))
    self.processButton.label:setText("Update message")
    self.processButton.onActivated = self.process

    -- Preview button
    self.previewButton = self:addSubview(
                             ui.Button(ui.Bounds {
            size = ui.Size(self.bounds.size.width * 0.8, 0.1, 0.05),
        }))
    self.previewButton:setColor({0.0, 1.0, 0, 1.0})
    self.previewButton.label:setText("Preview")
    self.previewButton.onActivated = self.preview

    -- Close button
    self.closeButton = self:addSubview(ui.Button(ui.Bounds {
        size = ui.Size(0.12, 0.12, 0.05),
    }))
    self.closeButton:setDefaultTexture(initial_assets.quit)
    self.closeButton.onActivated = function() self:removeFromSuperview() end

    self:layout()
end

function TelegramPopupView:layout()
    local height = 0.5

    self.closeButton.bounds:moveToOrigin():move(0.52, height / 2, 0.025)
    self.closeButton:setBounds()

    local pen = ui.Bounds {
        size = self.input.bounds.size:copy(),
        pose = ui.Pose(0, -height / 2, self.input.bounds.size.depth / 2),
    }
    pen:move(0, height - self.input.bounds.size.height, 0)
    self.input:setBounds(pen:copy())
    pen:move(0, -0.15, 0)
    self.processButton:setBounds(pen:copy())
    pen:move(0, -0.15, 0)
    self.previewButton:setBounds(pen:copy())

    self.bounds.size.height = height
    self:setBounds()
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
