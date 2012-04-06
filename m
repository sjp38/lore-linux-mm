Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id E07D56B004A
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 16:31:34 -0400 (EDT)
Received: by iajr24 with SMTP id r24so4808451iaj.14
        for <linux-mm@kvack.org>; Fri, 06 Apr 2012 13:31:34 -0700 (PDT)
Date: Fri, 6 Apr 2012 13:31:14 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC PATCH 0/2] Removal of lumpy reclaim
In-Reply-To: <20120406123439.d2ba8920.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1204061316580.3057@eggly.anvils>
References: <1332950783-31662-1-git-send-email-mgorman@suse.de> <20120406123439.d2ba8920.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Hugh Dickins <hughd@google.com>

On Fri, 6 Apr 2012, Andrew Morton wrote:
> On Wed, 28 Mar 2012 17:06:21 +0100
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > (cc'ing active people in the thread "[patch 68/92] mm: forbid lumpy-reclaim
> > in shrink_active_list()")
> > 
> > In the interest of keeping my fingers from the flames at LSF/MM, I'm
> > releasing an RFC for lumpy reclaim removal.
> 
> I grabbed them, thanks.

I do have a concern with this: I was expecting lumpy reclaim to be
replaced by compaction, and indeed it is when CONFIG_COMPACTION=y.
But when CONFIG_COMPACTION is not set, we're back to 2.6.22 in
relying upon blind chance to provide order>0 pages.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
