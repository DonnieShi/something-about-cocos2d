-- 设置长按 分步骤回调
function  meta:setLongTouchStepCallBack( widget )
    if widget == nil then
        printError(" widget is nil")
        return
    end

    local is_begin_tick = false
    local tick_total_num = 1000
    local tick_count = 0 

    -- 延时调用
    -- @params callback(function) 回调函数
    -- @params time(float) 延时时间(s)
    -- @return 定时器
    local delayDoSomething = function(_callback, time)
        local handle
        handle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(handle)
            _callback()
        end, time, false)
        return handle
    end

    local function beginTickFunc ( ... )
        if is_begin_tick and tick_count < tick_total_num then
            tick_count = tick_count + 1
            Game:showTips(tick_count)
            delayDoSomething(beginTickFunc,0.1)
        end
    end

    local endTickFunc = function  ( ... )
        print("EEEEEEEEEEEEEE")
    end

    -- 设置触摸事件
    local is_dragging = false
    local touchPanelBeganPoint, touchPanelMovePoint
    widget:onTouch(
        function(event)
            if event.name == "began" then
                is_dragging = false
                touchPanelBeganPoint = widget:getTouchBeganPosition()
                is_begin_tick = true  
                beginTickFunc()
            elseif event.name == "moved" then
                touchPanelMovePoint = widget:getTouchMovePosition()
                -- 当滑动超出一定距离后，取消动作
                if
                    math.abs(touchPanelMovePoint.x - touchPanelBeganPoint.x) >
                        Game.configs.global.SCREEN_TOUCH_MOVE_DISTANCE or
                    math.abs(touchPanelMovePoint.y - touchPanelBeganPoint.y) >
                        Game.configs.global.SCREEN_TOUCH_MOVE_DISTANCE
                 then
                    is_dragging = true
                    is_begin_tick = false
                    endTickFunc()
                end
            elseif event.name == "ended" then
                is_dragging = false
                is_begin_tick = false
                endTickFunc()

                -- 点击音效
                if isfunction(widget.getCustomProperty) then
                    local custom_property = string.split(widget:getCustomProperty(), "|")
                    for index = 1, #custom_property, 2 do
                        if custom_property[index] == "sound" then
                            Game.sound:playSound(custom_property[index + 1])
                        end
                    end
                end
            elseif event.name == "cancelled" then
                is_dragging = false
                is_begin_tick = false
                endTickFunc()
            end
        end
    )
end
