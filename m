Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 31880900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 15:36:34 -0400 (EDT)
Date: Wed, 13 Apr 2011 21:35:20 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm/thp: Use conventional format for boolean attributes
Message-ID: <20110413193520.GG5734@random.random>
References: <1300772711.26693.473.camel@localhost>
 <alpine.DEB.2.00.1104131202230.5563@chino.kir.corp.google.com>
 <20110413121925.55493041.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1104131224430.7052@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1104131224430.7052@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ben Hutchings <ben@decadent.org.uk>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

Hi,

On Wed, Apr 13, 2011 at 12:28:42PM -0700, David Rientjes wrote:
> On Wed, 13 Apr 2011, Andrew Morton wrote:
> 
> > It's a bit naughty to change the existing interface in 2.6.38.x but the time
> > window is small and few people will be affected and they were nuts to be
> > using 2.6.38.0 anyway ;)
> > 
> > I suppose we could support both the old and new formats for a while,
> > then retire the old format but I doubt if it's worth it.
> > 
> > Isn't there some user documentation which needs to be updated to
> > reflect this change?  If not, why not?  :)
> > 
> 
> Indeed there is, in Documentation/vm/transhuge.txt -- only for 
> /sys/kernel/mm/transparent_hugepage/khugepaged/defrag, though, we lack 
> documentation of debug_cow.

Well debug_cow only exists for CONFIG_DEBUG_VM so probably doesn't
need to be documented unless CONFIG_DEBUG_VM is documented in the
first place. It seems production kernels aren't using DEBUG_VM.

> Ben, do you have time to update the patch?  It sounds like this is 2.6.39 
> material.

I think it's fine for 2.6.39. Note that these tweaks are mostly for
debugging too, unless something's bad in compaction one wouldn't need
to tweak those. The only ones to tweak are the khugepaged parameters
and those are integers not booleans.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
