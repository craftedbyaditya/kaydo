import 'package:flutter/material.dart';

import '../../../../core/theme/fello_colors.dart';
import '../../../../domain/entities/feedback_form.dart';

class SetupProgress {
  const SetupProgress({
    required this.hasWorkspace,
    required this.hasForm,
    required this.hasPublishedForm,
    this.hasLogo = false,
  });

  factory SetupProgress.fromForms(
    List<FeedbackForm> forms, {
    bool hasLogo = false,
  }) {
    return SetupProgress(
      hasWorkspace: true,
      hasForm: forms.isNotEmpty,
      hasPublishedForm: forms.any((f) => f.isPublished),
      hasLogo: hasLogo,
    );
  }

  final bool hasWorkspace;
  final bool hasForm;
  final bool hasPublishedForm;
  final bool hasLogo;

  bool get isComplete => hasWorkspace && hasForm && hasPublishedForm;

  /// Optional items (logo/team) stay incomplete until those features exist.
  bool get showChecklist => !isComplete;
}

class SetupChecklistCard extends StatelessWidget {
  const SetupChecklistCard({
    super.key,
    required this.progress,
    required this.onCreateForm,
    this.onInviteTeam,
    this.onAddLogo,
  });

  final SetupProgress progress;
  final VoidCallback? onCreateForm;
  final VoidCallback? onInviteTeam;
  final VoidCallback? onAddLogo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: FelloColors.paper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FelloColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Get started',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          _ChecklistItem(
            done: progress.hasWorkspace,
            label: 'Create your workspace',
          ),
          _ChecklistItem(
            done: progress.hasForm,
            label: 'Create your first feedback form',
            onTap: progress.hasForm ? null : onCreateForm,
          ),
          _ChecklistItem(
            done: progress.hasPublishedForm,
            label: 'Publish your feedback form',
          ),
          _ChecklistItem(
            done: progress.hasLogo,
            label: 'Add your logo',
            muted: onAddLogo == null,
            onTap: progress.hasLogo ? null : onAddLogo,
          ),
          _ChecklistItem(
            done: false,
            label: 'Invite your team',
            muted: onInviteTeam == null,
            onTap: onInviteTeam,
          ),
        ],
      ),
    );
  }
}

class FirstTimeWelcome extends StatelessWidget {
  const FirstTimeWelcome({
    super.key,
    required this.onCreateForm,
    required this.creating,
  });

  final VoidCallback onCreateForm;
  final bool creating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      decoration: BoxDecoration(
        color: FelloColors.paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FelloColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Welcome to your workspace',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: creating ? null : onCreateForm,
            child: creating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Create your first feedback form'),
          ),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({
    required this.done,
    required this.label,
    this.onTap,
    this.muted = false,
  });

  final bool done;
  final String label;
  final VoidCallback? onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 20,
            color: done
                ? FelloColors.success
                : muted
                    ? FelloColors.chartMuted
                    : FelloColors.inkSoft,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: muted ? FelloColors.inkSoft : FelloColors.ink,
                decoration: done ? TextDecoration.lineThrough : null,
                decorationColor: FelloColors.inkSoft,
              ),
            ),
          ),
          if (onTap != null)
            Text(
              'Start',
              style: theme.textTheme.labelLarge?.copyWith(
                color: FelloColors.accent,
              ),
            ),
        ],
      ),
    );

    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: row,
    );
  }
}
