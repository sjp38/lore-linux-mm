Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA02098
	for <linux-mm@kvack.org>; Wed, 25 Feb 1998 18:01:52 -0500
Date: Wed, 25 Feb 1998 23:27:25 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: Fairness in love and swapping
In-Reply-To: <199802252139.WAA27196@boole.fs100.suse.de>
Message-ID: <Pine.LNX.3.91.980225232521.1846B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Dr. Werner Fink" <werner@suse.de>
Cc: sct@dcs.ed.ac.uk, torvalds@transmeta.com, nahshon@actcom.co.il, alan@lxorguk.ukuu.org.uk, paubert@iram.es, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 25 Feb 1998, Dr. Werner Fink wrote:

> > all remained fresh in the page age table.  The newcomer processes were
> > never able to keep a page in memory long enough for their age to compete
> > with the old process' pages, and so I had a number of identical
> > processes, half of which were fully swapped in and half of which were
> > swapping madly.
> 
>         /* Give the physical reallocated page a bigger start */
>         if (vma->vm_mm->rss < (MAP_NR(high_memory) >> 2))
>                 mem_map[MAP_NR(page)].age = (PAGE_INITIAL_AGE + PAGE_ADVANCE);
> 
> 
> would help a bit.  With this few lines a recently swapin page gets a bigger
> start by increasing the page age ... but only if the corresponding process to
> not overtake the physical memory.  This change is not very smart (e.g. its not
> a real comparsion by process swap count or priority) ... nevertheless it works
> for 2.0.33.

It looks kinda valid, and I'll try and tune it RSN. If
it gives any improvement, I'll send it to Linus for
inclusion.

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
