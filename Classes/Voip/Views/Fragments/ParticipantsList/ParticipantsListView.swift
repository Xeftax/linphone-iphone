/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
 *
 * This file is part of linphone-iphone
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */


import UIKit
import Foundation
import linphonesw

@objc class ParticipantsListView: DismissableView, UITableViewDataSource {
	
	// Layout constants
	
	
	let participantsListTableView =  UITableView()
	
	var callsDataObserver : MutableLiveDataOnChangeClosure<[CallData]>? = nil
	
	init() {
		super.init(title: VoipTexts.call_action_participants_list)
		
		
		let edit = CallControlButton(buttonTheme: VoipTheme.voip_edit, onClickAction: {
			// Todo (not implemented in Android yet as of 22.11.21)
		})
		super.headerView.addSubview(edit)
		edit.centerY().done()
		super.dismiss?.toRightOf(edit,withLeftMargin: dismiss_right_margin).centerY().done()
		
		
		// ParticipantsList
		super.contentView.addSubview(participantsListTableView)
		participantsListTableView.matchParentDimmensions().done()
		participantsListTableView.dataSource = self
		participantsListTableView.register(VoipParticipantCell.self, forCellReuseIdentifier: "VoipParticipantCell")
		participantsListTableView.allowsSelection = false
		if #available(iOS 15.0, *) {
			participantsListTableView.allowsFocus = false
		}
		participantsListTableView.separatorStyle = .singleLine
		participantsListTableView.separatorColor = .white
	
	
		CallsViewModel.shared.callsData.readCurrentAndObserve{ (callsData) in
			self.participantsListTableView.reloadData()
		}
		
		ConferenceViewModel.shared.isMeAdmin.readCurrentAndObserve { (meAdmin) in
			edit.isHidden = meAdmin != true
		}
			
	}

	
	// TableView datasource delegate
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let participants = ConferenceViewModel.shared.conferenceParticipants.value else {
			return 0
		}
		return participants.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:VoipParticipantCell = tableView.dequeueReusableCell(withIdentifier: "VoipParticipantCell") as! VoipParticipantCell
		guard let participantData = ConferenceViewModel.shared.conferenceParticipants.value?[indexPath.row] else {
			return cell
		}
		cell.selectionStyle = .none
		cell.participantData = participantData
		cell.owningParticpantsListView = self
		return cell
	}
	
	// View controller
	
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}