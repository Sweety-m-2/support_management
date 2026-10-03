import 'package:assigned_task_quantek/blocs/create_ticket/create_ticket_cubit.dart';
import 'package:assigned_task_quantek/blocs/create_ticket/create_ticket_state.dart';
import 'package:assigned_task_quantek/services/ticket_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateTicketScreen extends StatelessWidget {
  const CreateTicketScreen({super.key, required this.apiService});

  final TicketApiService apiService;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateTicketCubit(apiService),
      child: const _CreateTicketView(),
    );
  }
}

class _CreateTicketView extends StatefulWidget {
  const _CreateTicketView();

  @override
  State<_CreateTicketView> createState() => _CreateTicketViewState();
}

class _CreateTicketViewState extends State<_CreateTicketView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  String? _priority;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Ticket'),
        backgroundColor: Color(0xA20C8004),
      ),
      body: BlocListener<CreateTicketCubit, CreateTicketState>(
        listener: (context, state) {
          if (state is CreateTicketSuccess) {
            Navigator.of(context).pop(true);
          } else if (state is CreateTicketError &&
              state.validationErrors.isEmpty) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: BlocBuilder<CreateTicketCubit, CreateTicketState>(
          builder: (context, state) {
            final submitting = state is CreateTicketSubmitting;

            return SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 32,
                      vertical: isMobile ? 16 : 24,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Create a new support request',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),

                          const SizedBox(height: 20),

                          TextFormField(
                            controller: _titleController,
                            enabled: !submitting,
                            maxLength: 120,
                            decoration: const InputDecoration(
                              labelText: 'Title',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                _validationError('title', value),
                          ),

                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _descriptionController,
                            enabled: !submitting,
                            minLines: isMobile ? 4 : 5,
                            maxLines: isMobile ? 6 : 8,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                _validationError('description', value),
                          ),

                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _emailController,
                            enabled: !submitting,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Customer email',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                _validationError('customerEmail', value),
                          ),

                          const SizedBox(height: 16),

                          DropdownButtonFormField<String>(
                            initialValue: _priority,
                            decoration: const InputDecoration(
                              labelText: 'Priority',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Low',
                                child: Text('Low'),
                              ),
                              DropdownMenuItem(
                                value: 'Medium',
                                child: Text('Medium'),
                              ),
                              DropdownMenuItem(
                                value: 'High',
                                child: Text('High'),
                              ),
                            ],
                            onChanged: submitting
                                ? null
                                : (value) {
                                    setState(() => _priority = value);
                                  },
                            validator: (_) =>
                                _validationError('priority', _priority),
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            height: isMobile ? 48 : 52,
                            child: FilledButton.icon(
                              onPressed: submitting ? null : _submit,
                              icon: submitting
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.add),
                              label: Text(
                                submitting ? 'Creating...' : 'Create Ticket',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String? _validationError(String field, String? value) {
    final errors = CreateTicketCubit.validate(
      title: field == 'title' ? value ?? '' : _titleController.text,
      description: field == 'description'
          ? value ?? ''
          : _descriptionController.text,
      customerEmail: field == 'customerEmail'
          ? value ?? ''
          : _emailController.text,
      priority: _priority,
    );
    return errors[field];
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<CreateTicketCubit>().createTicket(
      title: _titleController.text,
      description: _descriptionController.text,
      customerEmail: _emailController.text,
      priority: _priority,
    );
  }
}
