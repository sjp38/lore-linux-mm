Received: from localhost (bcrl@localhost)
	by kvack.org (8.8.7/8.8.7) with SMTP id BAA07984
	for <linux-mm@kvack.org>; Thu, 18 Dec 1997 01:00:13 -0500
Date: Thu, 18 Dec 1997 01:00:12 -0500 (U)
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: Slow memory support
Message-ID: <Pine.LNX.3.95.971218005832.7940A-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
X-Sender: riel@mirkwood.dummy.home
Reply-To: H.H.vanRiel@fys.ruu.nl
To: Pavel Machek <pavel@Elf.mj.gts.cz>
cc: linux-mm <linux-mm@kvack.org>
Subject: Re: Slow memory support
In-Reply-To: <19971217221622.50179@Elf.mj.gts.cz>
Message-ID: <Pine.LNX.3.91.971218000718.887B-100000@mirkwood.dummy.home>
Approved: ObHack@localhost
Organization: none
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII

On Wed, 17 Dec 1997, Pavel Machek wrote:

> This is what I do. (I only put buffers there, for now). But, what
> about you have 64Meg of normal and 64Meg of slow memory? I doubt
> you'll find 64Meg worth of buffers and page tables.

Hmm, what about putting everything in slow memory, except
for executable code...
Or (with Ben's patch) we could move 'overly active' pages
to fast memory and other pages to slow memory, with a max
amount of pages we could move every second.

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
