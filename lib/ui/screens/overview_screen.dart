// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../blocs/reward/reward_bloc.dart';
// import '../../blocs/reward/reward_event.dart';
// import '../../blocs/reward/reward_state.dart';
// import '../../localization.dart';
// import '../widgets/reward_card.dart';
//
// class OverviewScreen extends StatefulWidget {
//   const OverviewScreen({Key? key}) : super(key: key);
//
//   @override
//   _OverviewScreenState createState() => _OverviewScreenState();
// }
//
// class _OverviewScreenState extends State<OverviewScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Initialisiere die Rewards, indem ein Event gesendet wird
//     context.read<RewardBloc>().add(LoadRewardsEvent());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final localizations = AppLocalizations.of(context)!;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(localizations.overview),
//       ),
//       body: BlocBuilder<RewardBloc, RewardState>(
//         builder: (context, state) {
//           if (state is RewardLoadingState) {
//             return Center(child: CircularProgressIndicator());
//           } else if (state is RewardErrorState) {
//             return Center(child: Text('${localizations.error}: ${state.message}'));
//           } else if (state is RewardLoadedState) {
//             final rewards = state.rewards;
//             if (rewards.isEmpty) {
//               return Center(child: Text(localizations.noRewardsFound));
//             }
//             return ListView.builder(
//               itemCount: rewards.length,
//               itemBuilder: (context, index) {
//                 final reward = rewards[index];
//                 return RewardCard(reward: reward);
//               },
//             );
//           } else {
//             return Center(child: Text(localizations.noRewardsFound));
//           }
//         },
//       ),
//     );
//   }
// }
