Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA10886
	for <linux-mm@kvack.org>; Tue, 9 Dec 1997 10:34:12 -0500
Date: Tue, 9 Dec 1997 15:53:29 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: Re: Ideas for memory management hackers.
In-Reply-To: <348D3B36.673BEE82@nospam.isltd.insignia.co.uk>
Message-ID: <Pine.LNX.3.91.971209154819.584H-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Stephen Thomas <stephen.thomas@insignia.co.uk>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Dec 1997, Stephen Thomas wrote:

> Should vhand have any effect on memory utilisation figures,
> as reported by /proc/meminfo?  If so, then vhand did not seem
> to be achieving much, for all its hard work ...

I have integrated mmap aging in kswapd, without the need for
vhand, in 2.1.71 (experimental). As ppp isn't working in 2.1.71
I'm back to 2.1.66 now, but I have seen kswapd use over 10% of
CPU for short times now :(

But it doesn't have the disadvantage of having to scan constantly,
and it seemed to work better than vhand (it seems that page->accessed
isn't updated automatically, and has to be done via pte->flags in
the page-table scanning done by kswapd... This would vhand have
a fundamental design flaw, which would explain why some people
saw a boost in performance, while others saw performance worsen...

I think I'll send it to Linus (together with Zlatko's
big-order hack) as a bug-fix (we're on feature-freeze after all:)
for inclusion in 2.1.72...

opinions please,

Rik.

--
Send Linux memory-management wishes to me: I'm currently looking
for something to hack...
