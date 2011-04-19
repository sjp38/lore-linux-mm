Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 959688D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 07:10:00 -0400 (EDT)
Date: Tue, 19 Apr 2011 13:09:56 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH followup] mm: get rid of CONFIG_STACK_GROWSUP || CONFIG_IA64
Message-ID: <20110419110956.GD21689@tiehlicka.suse.cz>
References: <20110415135144.GE8828@tiehlicka.suse.cz>
 <alpine.LSU.2.00.1104171952040.22679@sister.anvils>
 <20110418100131.GD8925@tiehlicka.suse.cz>
 <20110418135637.5baac204.akpm@linux-foundation.org>
 <20110419091022.GA21689@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110419091022.GA21689@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

While I am in the cleanup mode. We should use VM_GROWSUP rather than
tricky CONFIG_STACK_GROWSUP||CONFIG_IA64.

What do you think?
--- 
