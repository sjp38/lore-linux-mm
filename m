Message-ID: <3D7798CE.D74518F1@zip.com.au>
Date: Thu, 05 Sep 2002 10:47:58 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: MAP_SHARED handling
References: <3D7705C5.E41B5D5F@zip.com.au> <E17mzs8-00068y-00@starship>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Daniel Phillips wrote:
> 
> ...
> 
> Why not just ensure the page is scheduled for writing, sometime,
> we don't care exactly when as long as it's relatively soon.  Just bump
> the page's mapping to the hot end of your writeout list and let things
> take their course.

Good point.  Marking the pages dirty and not starting IO on them
exposes them to pdflush.  Chances are, by the time those pages
come around again, they'll all be under writeback or clean.

And, umm, yes.  If a pass across all the zones in the classzone
doesn't free enough stuff, we run wakeup_bdflush() and then
take an up-to-quarter-second nap.  So pdflush will immediately
start working on all those pages which we just marked dirty.
It looks about right.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
