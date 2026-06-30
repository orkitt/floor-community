import 'package:flutter/material.dart';

import 'task.dart';
import 'task_dao.dart';

class TasksTextField extends StatefulWidget {
  final TaskDao dao;

  const TasksTextField({super.key, required this.dao});

  @override
  State<TasksTextField> createState() => _TasksTextFieldState();
}

class _TasksTextFieldState extends State<TasksTextField> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final text = _textController.text.trim();
    _textController.clear();

    if (text.isNotEmpty) {
      final task = Task.optional(message: text, type: TaskType.task);
      await widget.dao.insertTask(task);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      // Gives it breathing room from the screen edges
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), // Smooth rounded corners
          border: Border.all(
            color: Colors.grey.shade300, // Elegant subtle border
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04), // Soft, premium elevation
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Type task here...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: InputBorder.none, // Kept none here because the container handles the border
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                ),
                onSubmitted: (_) => _handleSave(),
              ),
            ),
            // Premium Floating Action Style Button
            Material(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _handleSave,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    Icons.arrow_upward_rounded, // Apple/Modern style submit arrow
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}