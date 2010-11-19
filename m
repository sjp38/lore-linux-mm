Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id ABADB6B0071
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 10:46:31 -0500 (EST)
Date: Fri, 19 Nov 2010 10:45:40 -0500
From: Ted Ts'o <tytso@mit.edu>
Subject: Re: [PATCH 0/8] Use memory compaction instead of lumpy reclaim
 during high-order allocations
Message-ID: <20101119154540.GG10039@thunk.org>
References: <1290010969-26721-1-git-send-email-mel@csn.ul.ie>
 <20101117154641.51fd7ce5.akpm@linux-foundation.org>
 <20101118081254.GB8135@csn.ul.ie>
 <20101118172627.cf25b83a.kamezawa.hiroyu@jp.fujitsu.com>
 <20101118083828.GA24635@cmpxchg.org>
 <20101118092044.GE8135@csn.ul.ie>
 <20101118114928.ecb2d6b0.akpm@linux-foundation.org>
 <20101119104856.GB28613@csn.ul.ie>
 <4B8266CB-F658-4CC8-BCA3-677C22BAFAE0@mit.edu>
 <20101119140532.GH28613@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101119140532.GH28613@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Nov 19, 2010 at 02:05:32PM +0000, Mel Gorman wrote:
> > 
> > How about making the default before 2.6.40, as an initial step?
> > 
> 
> It'd be a reasonable way of ensuring it's being tested everywhere
> and not by those that are interested or using distro kernel configs.
> I guess we'd set to "default y" in the same patch that adds the note to
> feature-removal-schedule.txt.

I'd suggest doing it now (or soon, before 2.6.40), just to make sure
there aren't massive complaints about performance regressions, etc.,
and then deprecating it at say 2.6.42, and then waiting 6-9 months
before removing it.  But, I'm a bit more conservative about making
such changes.

(Said the person who has reluctantly agreed to keep the minixdf mount
option after we found users when we tried deprecating it.  :-)

       	     	      	    	    	  - Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
