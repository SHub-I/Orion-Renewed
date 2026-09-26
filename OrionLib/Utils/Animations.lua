-- OrionLib Gen 2 - Small animation helpers
-- File: OrionLib/Utils/Animations.lua

local TweenService = game:GetService("TweenService")

local Anim = {}

function Anim.FadeIn(instance, time, props)
    time = time or 0.25
    props = props or {}
    instance.Visible = true
    local tween = TweenService:Create(instance, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

function Anim.FadeOut(instance, time, props)
    time = time or 0.25
    props = props or {}
    local tween = TweenService:Create(instance, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    tween:Play()
    tween.Completed:Wait()
    if props.Visible == false then instance.Visible = false end
    return tween
end

function Anim.Pulse(instance, scaleFrom, scaleTo, time)
    time = time or 0.35
    local orig = instance.Size
    local tween1 = TweenService:Create(instance, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = orig * scaleTo})
    local tween2 = TweenService:Create(instance, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = orig * scaleFrom})
    tween1:Play()
    tween1.Completed:Wait()
    tween2:Play()
    return tween2
end

return Anim
