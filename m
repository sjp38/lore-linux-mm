Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 538A66B00DD
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 08:45:19 -0500 (EST)
Date: Wed, 23 Nov 2011 13:45:13 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 7/7] mm: compaction: Introduce sync-light migration for
 use by compaction
Message-ID: <20111123134512.GN19415@suse.de>
References: <1321900608-27687-1-git-send-email-mgorman@suse.de>
 <1321900608-27687-8-git-send-email-mgorman@suse.de>
 <1321945011.22361.335.camel@sli10-conroe>
 <CAPQyPG4DQCxDah5VYMU6PNgeuD_3WJ-zm8XpL7V7BK8hAF8OJg@mail.gmail.com>
 <20111123110041.GM19415@suse.de>
 <CAPQyPG588_q1diT8KyPirUD9MLME6SanO-cSw1twzhFiTBWgCw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAPQyPG588_q1diT8KyPirUD9MLME6SanO-cSw1twzhFiTBWgCw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Linux-MM <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Nov 23, 2011 at 09:05:08PM +0800, Nai Xia wrote:
> > <SNIP>
> >
> > Where are you adding this check?
> >
> > If you mean in __unmap_and_move(), the check is unnecessary unless
> > another subsystem starts using sync-light compaction. With this series,
> > only direct compaction cares about MIGRATE_SYNC_LIGHT. If the page is
> 
> But I am still a little bit confused that if MIGRATE_SYNC_LIGHT is only
> used by direct compaction and  another mode can be used by it:
> MIGRATE_ASYNC also does not write dirty pages, then why not also
> do an (current->flags & PF_MEMALLOC) test before writing out pages,

Why would it be necessary?
Why would it be better than what is there now?

> like we already did for the page lock condition, but adding a new mode
> instead?
> 

I'm afraid I am missing the significance of your question or how it
might apply to the problem at hand.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
