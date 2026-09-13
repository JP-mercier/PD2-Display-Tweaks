if Global.level_data and Global.level_data.level_id == "mus" then
    if not DisplayTweaks then
        DisplayTweaks = {_brush = Draw:brush(), drawn_tiles = {}, tile_data = {}}
        local hook_name = Network:is_server() and "on_executed" or "client_on_executed"

        function DisplayTweaks:init(hook)
            if hook == "core/lib/managers/coreworldinstancemanager" then
                Hooks:PostHook(CoreWorldInstanceManager, "add_instance_data", "DT_AddInstanceData", function(manager, instance)
                    if instance.name:match("^mus_tile_[a-i]00[1-6]$") then
                        local base_index = instance.start_index + manager:start_offset_index()
                        self.tile_data[base_index + 100005] = base_index + 100001
                    end
                end)
            elseif hook == "lib/managers/missionmanager" then
                function DisplayTweaks:add_drawable(element)
                    if type(self.drawn_tiles) == "table" and type(element) == "table" then
                        local shape = element._shapes[1]

                        if type(shape) == "table" then
                            local rot = shape:rotation()

                            table.insert(self.drawn_tiles, {
                                pos = shape:position() - rot:z() * (shape._properties.height - 20) / 2,
                                width = rot:x() * shape._properties.width / 2,
                                depth = rot:y() * shape._properties.depth / 2,
                                height = Vector3(0, 0, 0.3)
                            })
                        end
                    end
                end

                Hooks:PostHook(MissionScriptElement, "init", "DT_InitTiles", function(element, script, data)
                    if data.id == 101517 or data.id == 101784 then
                        Hooks:PostHook(element, hook_name, "DT_ClearTiles", function()
                            if data.id == 101784 then
                                Hooks:RemovePostHook("DT_UpdateDigitalGui")
                                Hooks:RemovePostHook("DT_HighlightTile")
                                Hooks:RemovePostHook("DT_UpdateTiles")
                                Hooks:RemovePostHook("DT_ClearTiles")
                            end

                            self.drawn_tiles = {}
                        end)
                    elseif type(self.tile_data[data.id]) == "number" then
                        Hooks:PostHook(element, hook_name, "DT_HighlightTile", function()
                            self:add_drawable(script:element(self.tile_data[data.id]))
                        end)
                    end
                end)

                Hooks:PostHook(MissionScript, "update", "DT_UpdateTiles", function()
                    for _, tile in ipairs(self.drawn_tiles) do
                        self._brush:box(tile.pos, tile.width, tile.depth, tile.height)
                    end
                end)
            else
                Hooks:PostHook(DigitalGui, "init", "DT_InitDigitalGui", function(gui, unit)
                    if alive(unit) and unit:name():key() == "5a7e636bc31e53b2" then
                        Hooks:PostHook(gui, "_update_timer_text", "DT_UpdateDigitalGui", function()
                            if gui._timer > 0 then
                                if gui._timer <= 2.5 then
                                    self._brush:set_color(Color((gui._timer / 2.5) ^ 0.7 * 0.03, 1, 0, 0))
                                elseif gui._timer <= 15 then
                                    self._brush:set_color(Color(0.03, 1, (gui._timer - 5) / 10 ^ 0.3, 0))
                                elseif gui._timer <= 30 then
                                    self._brush:set_color(Color(0.03, 1 - (gui._timer - 15) / 30 ^ 0.3, 1, 0))
                                else
                                    self._brush:set_color(Color(0.03, 0, 1, 0))
                                end
                            end
                        end)

                        self._brush:set_color(Color(0.03, 0, 1, 0))
                    end
                end)
            end
        end
    end

    DisplayTweaks:init(RequiredScript)
end