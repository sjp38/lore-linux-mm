Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA29072
	for <linux-mm@kvack.org>; Mon, 2 Mar 1998 12:02:22 -0500
Date: Mon, 2 Mar 1998 17:19:41 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: Fairness in love and swapping
In-Reply-To: <199802271941.TAA01151@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.91.980302171448.29405D-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: "Dr. Werner Fink" <werner@suse.de>, torvalds@transmeta.com, nahshon@actcom.co.il, alan@lxorguk.ukuu.org.uk, paubert@iram.es, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Feb 1998, Stephen C. Tweedie wrote:

> > AFAIK, mapped images aren't part of a proces' RSS, but
> > are page-cached (page->inode type of RSS). And swapping
> > of those vma's _is_ done in shrink_mmap() in filemap.c.
> 
> No, absolutely not.  These pages are certainly present in the page
[snip]
> > But if I've overlooked something, I'd really like to hear about
> > it... A bit of a clue never hurts when coding up new patches :-)
> 
> You're welcome. :)

Nevertheless, the system seems to run smoother when the
page-cache pages aren't thrown away immediately, but aged
as normal pages are. Read-ahead pages _are_ sometimes
freed before they're actually used, so in this case the
system _will_ have to read them again. But maybe a 'true'
LRU implementation for the 'hardy-referenced' pages might
be better (with a sysctl tunable timing thing).

start:
	page->age |= (1 << lru_age_factor)
referenced:
	page->age >>= 1
	page->age |= (1 << lru_age_factor)
not-referenced:
	page->age >>=1

grtz,

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
