Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA20106
	for <linux-mm@kvack.org>; Thu, 26 Feb 1998 19:24:55 -0500
Date: Fri, 27 Feb 1998 00:34:59 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: Fairness in love and swapping
In-Reply-To: <199802262244.WAA03924@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.91.980227003050.6476B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: "Dr. Werner Fink" <werner@suse.de>, torvalds@transmeta.com, nahshon@actcom.co.il, alan@lxorguk.ukuu.org.uk, paubert@iram.es, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Feb 1998, Stephen C. Tweedie wrote:

> > Without my mmap-age patch, page cache pages aren't aged
> > at all... They're just freed whenever they weren't referenced
> > since the last scan. The PAGE_AGE_VALUE is quite useless IMO
> > (but I could be wrong, Stephen?).
> 
> They _are_ useful for mapped images such as binaries (which are swapped
> out by vmscan.c, not filemap.c), but not for otherwise unused, pure
> cached pages.

AFAIK, mapped images aren't part of a proces' RSS, but
are page-cached (page->inode type of RSS). And swapping
of those vma's _is_ done in shrink_mmap() in filemap.c.

Furthermore, it's quite useful if your read-ahead pages
stay in memory for a while so you don't read them two
or even three times before they're actually used.

But if I've overlooked something, I'd really like to
hear about it... A bit of a clue never hurts when
coding up new patches :-)

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
