Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA11727
	for <linux-mm@kvack.org>; Tue, 25 Nov 1997 10:11:24 -0500
Date: Tue, 25 Nov 1997 15:58:56 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Pageable pagetables.
Message-ID: <Pine.LNX.3.91.971125155707.535A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-kernel <linux-kernel@vger.rutgers.edu>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi there,

I've had some mails about whether Linux could be made
to swap pagetables.
I think this might be a Good Thing to do, but I keep
asking myself what the MMUs from the different architectures
would do when looking up a pagetable would cause a fault...

Anyone have a clue?

Rik.

----------
Send Linux memory-management wishes to me: I'm currently looking
for something to hack...
