Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA10827
	for <linux-mm@kvack.org>; Tue, 9 Dec 1997 10:27:08 -0500
Date: Tue, 9 Dec 1997 15:41:23 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: Re: pageable page tables
In-Reply-To: <19971209122346.02899@Elf.mj.gts.cz>
Message-ID: <Pine.LNX.3.91.971209153832.584E-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@Elf.mj.gts.cz>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Dec 1997, Pavel Machek wrote:

> > > Simple task might be 'memory priorities'. Something like priorities
> > > for scheduler but for memory. (I tried to implement them, and they
> > > gave <1% performance gain ;-), but I have interface to set such
> > > parameter if you want to play).
> > 
> > sounds rather good... (swapout-priorities??)
> 
> But proved to be pretty ineffective. I came to this idea when I
> realized that to cook machine, running 100 processes will not hurt too
> much. But running 10 processes, 50 megabytes each will cook almost
> anything...

what about:

if (page->age - p->mem_priority)
	exit 0 / goto next;
else {
	get_rid_of(page);
	and_dont_show_your_face_again_for_some_time(page);
}

effectively putting the program to sleep if:
- this page faults again soon
- memory is still tight

hmm, just an idea...

Rik.

--
Send Linux memory-management wishes to me: I'm currently looking
for something to hack...
