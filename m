Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA01301
	for <linux-mm@kvack.org>; Mon, 17 Nov 1997 18:50:45 -0500
Date: Mon, 17 Nov 1997 22:15:46 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: memory management wishes...
In-Reply-To: <gordo-971117164959.A013341@gringo.telsur.cl>
Message-ID: <Pine.LNX.3.91.971117221247.13935C-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Gordon Oliver <gordo@telsur.cl>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Nov 1997, Gordon Oliver wrote:

> ... Rik van Riel said ...
> >Send Linux memory-management wishes to me: I'm currently looking
> >for something to hack...
> 
> I'd like to see an experiment done where some aggressive swapping code marks
> pages for swapping and makes them "non-resident" without actually doing the
> swapping. I.e.
> 	1) mark pages for swapping aggressively, marking them non-resident
> 		in the page tables at the same time.
> 	2) gather statistics for pages that have been marked non-resident,
> 		trying to figure out the "value" of a page.
> 	3) Use these statistics to swap out little used pages rapidly...
> 
> The advantage is that it gives the possibility of aggressively swapping without
> taking the entire penalty... I'm not sure if this will actually help in the
> end, but it is cool research, and might get a big win.

I believe this is what 'real' unixen already do, they have an
'inactive' list of not-so-often used pages that are ready to
be swapped out. They even prepage the head of the inactive list.
If a page from the inactive list _is_ used before being swapped
out, it is 'reactivated'.

To implement this we would need:
- a big chunk of memory to hold the list
- a mechanism to build the list
- a preswapping/freeing daemon (easy)
- the willingness to code all of this

Rik.

----------
Send Linux memory-management wishes to me: I'm currently looking
for something to hack...
