Received: from localhost (bcrl@localhost)
	by kvack.org (8.8.7/8.8.7) with SMTP id BAA08071
	for <linux-mm@kvack.org>; Thu, 18 Dec 1997 01:02:28 -0500
Date: Thu, 18 Dec 1997 01:02:27 -0500 (EST)
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: memory priorities
Message-ID: <Pine.LNX.3.95.971218010132.7940C-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Grr... I should 'fix' this ;-)
---------- Forwarded message ----------
Date: Thu, 18 Dec 1997 00:51:42 -0500
From: owner-linux-mm@kvack.org
To: owner-linux-mm@kvack.org
Subject: BOUNCE linux-mm: Invalid 'Approved:' header

>From owner-linux-mm@kvack.org  Thu Dec 18 00:51:40 1997
Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id AAA07896
	for <linux-mm@kvack.org>; Thu, 18 Dec 1997 00:51:38 -0500
Received: from mirkwood.dummy.home (root@anx1p8.fys.ruu.nl [131.211.33.97])
	by max.fys.ruu.nl (8.8.7/8.8.7/hjm) with ESMTP id GAA14312;
	Thu, 18 Dec 1997 06:45:51 +0100 (MET)
Received: (from riel@localhost) by mirkwood.dummy.home (8.6.12/8.6.9) id AAA01388; Thu, 18 Dec 1997 00:12:55 +0100
Date: Thu, 18 Dec 1997 00:12:53 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
X-Sender: riel@mirkwood.dummy.home
Reply-To: H.H.vanRiel@fys.ruu.nl
To: Pavel Machek <pavel@Elf.mj.gts.cz>
cc: linux-mm <linux-mm@kvack.org>
Subject: memory priorities
In-Reply-To: <19971217221100.40232@Elf.mj.gts.cz>
Message-ID: <Pine.LNX.3.91.971218001014.887C-100000@mirkwood.dummy.home>
Approved: ObHack@localhost
Organization: none
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII

On Wed, 17 Dec 1997, Pavel Machek wrote:

[snip Pavel (?) implemented memory priorities]
> > > But proved to be pretty ineffective. I came to this idea when I
> > > realized that to cook machine, running 100 processes will not hurt too
> > > much. But running 10 processes, 50 megabytes each will cook almost
> > > anything...
> > 
> > what about:
> > 
> > if (page->age - p->mem_priority)
> > 	exit 0 / goto next;
> > else {
> > 	get_rid_of(page);
> > 	and_dont_show_your_face_again_for_some_time(page);
> > }
> 
> I tried only manipulating comparasion, and not putting in into
> sleep. I did not find benchmark where it does any performance
> gain. ;-) Seems like it does nearly nothing.

Well, if you only swap out the page, it will be swapped
in quite soon and the only effect is that your system
will have more pagefaults...

If there is some free field in the page-table (once the
page gets swapped out) we could use it to indicate that
the system should wait some time with swapping this one
in again...

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
