Received: from mail.ccr.net (ccr@alogconduit1ap.ccr.net [208.130.159.16])
	by kvack.org (8.8.7/8.8.7) with ESMTP id XAA18105
	for <linux-mm@kvack.org>; Tue, 5 Jan 1999 23:37:06 -0500
Subject: Re: Why don't shared anonymous mappings work?
References: <199901051251.FAA15706@nyx10.nyx.net>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 05 Jan 1999 22:05:06 -0600
In-Reply-To: Colin Plumb's message of "Tue, 5 Jan 1999 05:51:52 -0700 (MST)"
Message-ID: <m1d84thwr1.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Colin Plumb <colin@nyx.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Take a page map it into two processes.
Swap the page out from both processes to disk.
The swap address is now in the pte's.
Bring that page into process 1.
Dirty the page, thus causing a new swap entry to be allocated.
   ( The write once rule)
Swap the page out of process 1.

Oops process 1 and process 2 have different pte's for the same
page.

Since we don't have any form of reverse page table entry
preventing that last case is difficult to do effciently.

Eric

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
