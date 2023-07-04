'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 27/05/2021 by Igor Malasevschi

function createTasksGroup(tasks as dynamic, onCompleteFuncName as string) as object

    instance = {
        tasks: tasks,
        onCompleteFuncName: onCompleteFuncName,

        invoke: sub()
            for each task in m.tasks
                if (task.state <> "RUN") then
                    task.control = "RUN"
                    task.observeField("state", m.onCompleteFuncName)
                    task.Grouping = m
                end if
            end for
        end sub
    }

    instance.invoke()
    return instance
end function

function tasksGroupIsFinished(event as dynamic) as boolean
    taskNode = event.GetRoSGNode()

    tasks = ArrayFilter(taskNode.Grouping.tasks, function(item)
        return item.state = "stop"
    end function)

    return taskNode.Grouping.tasks.count() = tasks.count()
end function



function getTasksResponse(event as dynamic) as dynamic
    taskNode = event.GetRoSGNode()
    result = []
    for each task in taskNode.grouping.tasks
        result.push(task.response)
    end for
    return result
end function

function getTasksGroupTasks(event as dynamic) as dynamic
    taskNode = event.GetRoSGNode()
    result = []
    for each task in taskNode.Grouping.tasks
        result.push(task.response)
    end for
    return result
end function



function ArrayFilter(array as dynamic, comparer as dynamic) as dynamic
    result = []

    for each item in array
        if (comparer(item)) then
            result.push(item)
        end if
    end for

    return result
end function
