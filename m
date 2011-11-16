Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id CC05C6B006E
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 20:09:43 -0500 (EST)
Subject: Re: [patch v2 4/4]thp: improve order in lru list for split huge
 page
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20111115181901.GK4414@redhat.com>
References: <1321340661.22361.297.camel@sli10-conroe>
	 <20111115181901.GK4414@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 16 Nov 2011 09:19:26 +0800
Message-ID: <1321406366.22361.299.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>

On Wed, 2011-11-16 at 02:19 +0800, Andrea Arcangeli wrote:
> On Tue, Nov 15, 2011 at 03:04:21PM +0800, Shaohua Li wrote:
> > Put the tail subpages of an isolated hugepage under splitting in the
> > lru reclaim head as they supposedly should be isolated too next.
> > 
> > Queues the subpages in physical order in the lru for non isolated
> > hugepages under splitting. That might provide some theoretical cache
> > benefit to the buddy allocator later.
> > 
> > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> 
> Perfect all 4 patches. You've been reading my mind because I was
> thinking it'd be good to merge these 4 which are strightforward
> before going into 5/5.
yep, I'm thinking to post that one separately, they are not related
anyway. Still working on it.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
