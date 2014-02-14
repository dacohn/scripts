tell application "TaskPaper"
	tell front document
		repeat with _task in search with query "project != Archive and @tomorrow"
			if entry type of _task is not project type then
				-- remove common tags that won't matter after archiving
				repeat with _tag in {"tomorrow"}
					if exists (tag named _tag of _task) then delete tag named _tag of _task
				end repeat
				
				-- add the today tag
				tell _task to make tag with properties {name:"today"}
			end if
		end repeat

	end tell

	save front document
end tell
