local PROFILE_IMAGE = script:GetCustomProperty("ProfileImage"):WaitForObject()

local LOCAL_PLAYER = Game.GetLocalPlayer()

Task.Wait()
PROFILE_IMAGE:SetPlayerProfile(LOCAL_PLAYER)