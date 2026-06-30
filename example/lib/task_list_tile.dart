import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Optional: Use to format dates cleanly if preferred

import 'task.dart';
import 'task_dao.dart';

class TaskListCell extends StatelessWidget {
  final Task task;
  final TaskDao dao;

  const TaskListCell({super.key, required this.task, required this.dao});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Formatted time (e.g., "14:32" or "3:22 PM") for a cleaner look than a massive ISO string
    final timeString = DateFormat.jm().format(task.timestamp); 

    return Padding(
      // Padding gives the floating cards space between each other
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16), // Matches the text field radius
        child: Dismissible(
          key: Key('${task.hashCode}'),
          direction: DismissDirection.horizontal,
          
          // PREMIUM SWIPE RIGHT (Change Status)
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 24),
            color: Colors.deepPurple.shade600, // Premium modern green
            child: const Row(
              children: [
                Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 22),
                SizedBox(width: 8),
                Text(
                  'Change Status',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 0.3),
                ),
              ],
            ),
          ),

          // PREMIUM SWIPE LEFT (Delete)
          secondaryBackground: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            color: Colors.deepOrange.shade600, // Premium modern red
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Delete',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 0.3),
                ),
                SizedBox(width: 8),
                Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
              ],
            ),
          ),

          confirmDismiss: (direction) async {
            String? statusMessage;
            switch (direction) {
              case DismissDirection.endToStart:
                await dao.deleteTask(task);
                statusMessage = 'Removed task';
                break;
              case DismissDirection.startToEnd:
                final tasksLength = TaskStatus.values.length;
                final nextIndex = (tasksLength + task.statusIndex + 1) % tasksLength;
                final taskCopy = task.copyWith(
                  status: TaskStatus.values[nextIndex],
                );
                await dao.updateTask(taskCopy);
                statusMessage = 'Updated task to: ${taskCopy.statusTitle}';
                break;
              default:
                break;
            }

            if (statusMessage != null && context.mounted) {
              final scaffoldMessengerState = ScaffoldMessenger.of(context);
              scaffoldMessengerState.hideCurrentSnackBar();
              scaffoldMessengerState.showSnackBar(
                SnackBar(
                  content: Text(statusMessage),
                  behavior: SnackBarBehavior.floating, // Floating snackbar to look modern
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
            return statusMessage != null;
          },

          // THE PREMIUM CARD INTERIOR
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.grey.shade200, // Super crisp clean border
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02), // Soft premium elevation
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                task.message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    // Dynamic tag color based on task completion
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: task.statusTitle.toLowerCase() == 'done' 
                            ? Colors.deepPurple.withOpacity(0.1)
                            : theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        task.statusTitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: task.statusTitle.toLowerCase() == 'done' 
                              ? Colors.deepPurple.shade700
                              : theme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              trailing: Text(
                timeString,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}