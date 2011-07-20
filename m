Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 6B88F6B004A
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 23:53:43 -0400 (EDT)
Date: Wed, 20 Jul 2011 13:53:32 +1000
From: Dave Chinner <dchinner@redhat.com>
Subject: Re: vmscan: shrinker->nr updates race and go wrong
Message-ID: <20110720035332.GC24009@devil.redhat.com>
References: <20110719200826.GC6445@shale.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110719200826.GC6445@shale.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <error27@gmail.com>
Cc: "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Tue, Jul 19, 2011 at 11:08:26PM +0300, Dan Carpenter wrote:
> Hi Dave,
> 
> There is a sign error in e5b94d7463e0 "vmscan: shrinker->nr updates
> race and go wrong"
> 
> mm/vmscan.c +274 shrink_slab(41)
> 	warn: unsigned 'total_scan' is never less than zero.
> 
>    268                  total_scan = nr;
>    269                  max_pass = do_shrinker_shrink(shrinker, shrink, 0);
>    270                  delta = (4 * nr_pages_scanned) / shrinker->seeks;
>    271                  delta *= max_pass;
>    272                  do_div(delta, lru_pages + 1);
>    273                  total_scan += delta;
>    274                  if (total_scan < 0) {
>                             ^^^^^^^^^^^^^^
> total_scan is unsigned so it's never less than zero here.

Obviously. You'd think a kernel build would warn about that given
that it's almost always a bug, wouldn't you?

I'll send a patch to fix it up....

Cheers,

Dave.
-- 
Dave Chinner
dchinner@redhat.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
