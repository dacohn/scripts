set archivedTasks to ""
set projectList to {}

on tpdate(mydate)
	set y to text -4 thru -1 of ("0000" & (year of mydate))
	set m to text -2 thru -1 of ("00" & ((month of mydate) as integer))
	set d to text -2 thru -1 of ("00" & (day of mydate))
	
	return y & "-" & m & "-" & d
end tpdate

set theDate to tpdate((current date))

tell application "TaskPaper"
	tell front document
		-- don't care which file your log entry came from?
		-- comment the next line out
		set archivedTasks to "## Completed tasks from " & name & return
		repeat with _task in search with query "project != Archive and @done"
			if entry type of _task is not project type then
				-- remove common tags that won't matter after archiving
				repeat with _tag in {"na", "next", "priority", "waiting", "done"}
					if exists (tag named _tag of _task) then delete tag named _tag of _task
				end repeat
				
				-- Get current project name				
				set projectName to (name of containing project of _task)
				
				-- If project name is not in projectList, add string to achivedTask and projectList
				if projectList does not contain projectName then
					set end of projectList to projectName
					set archivedTasks to archivedTasks & return & "### " & projectName & return
				end if
				
				-- append the full text of the entry, including tags, to our log
				set archivedTasks to archivedTasks & (text line of _task)
				
				-- add the done tag back
				tell _task to make tag with properties {name:"done", value:(theDate as rich text)}
				
				-- if there's no project tag on the task, 
				-- add the task's current project as a tag
				if not (exists (tag named "project" of _task)) then
					tell _task to make tag with properties {name:"project", value:(name of containing project of _task as rich text)}
				end if
				
				-- archive it
				move entry id (id of _task) to beginning of entries of project "Archive"
			end if
		end repeat
	end tell

	save from document
end tell
-- send the accumulated results to Day One via the command line tool
-- http://dayoneapp.com/faq/#commandlineinterface
-- You'll need to run `ln -s "/Applications/Day One/Day One.app/Contents/MacOS/dayone" /usr/local/bin/dayone` to have it accessible at this path
do shell script "echo " & (quoted form of archivedTasks) & "|tr -d \"\\t\"|/usr/local/bin/dayone new"
