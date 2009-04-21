Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6C85D6B0047
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 04:20:50 -0400 (EDT)
Date: Tue, 21 Apr 2009 10:19:03 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/3] mm: fix pageref leak in do_swap_page()
Message-ID: <20090421081903.GA2527@cmpxchg.org>
References: <1240259085-25872-1-git-send-email-hannes@cmpxchg.org> <20090421031419.GB30001@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090421031419.GB30001@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 21, 2009 at 08:44:20AM +0530, Balbir Singh wrote:
> * Johannes Weiner <hannes@cmpxchg.org> [2009-04-20 22:24:43]:
> 
> > By the time the memory cgroup code is notified about a swapin we
> > already hold a reference on the fault page.
> > 
> > If the cgroup callback fails make sure to unlock AND release the page
> > or we leak the reference.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> Seems reasonable to me, could you make the changelog more verbose and
> mention that lookup_swap_cache() gets a reference to the page and we
> need to release the extra reference.

Okay, I will add that information.

> BTW, have you had any luck reproducing the issue? How did you catch
> the problem?

I reviewed all the exit points when I shuffled code around in there
for another series that uses a lighter version of do_wp_page() for
swap write-faults.  I never triggered that problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
