Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D95846B003D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 13:48:43 -0400 (EDT)
Date: Tue, 17 Mar 2009 10:43:08 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <20090317171049.GA28447@random.random>
Message-ID: <alpine.LFD.2.00.0903171023390.3082@localhost.localdomain>
References: <1237007189.25062.91.camel@pasglop> <200903141620.45052.nickpiggin@yahoo.com.au> <20090316223612.4B2A.A69D9226@jp.fujitsu.com> <alpine.LFD.2.00.0903161739310.3082@localhost.localdomain> <20090317121900.GD20555@random.random>
 <alpine.LFD.2.00.0903170929180.3082@localhost.localdomain> <alpine.LFD.2.00.0903170950410.3082@localhost.localdomain> <20090317171049.GA28447@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Tue, 17 Mar 2009, Andrea Arcangeli wrote:

> On Tue, Mar 17, 2009 at 10:01:06AM -0700, Linus Torvalds wrote:
> > That same swapout+swapin problem seems to lose the dirty bit on a O_DIRECT 
> 
> I think the dirty bit is set in dio_bio_complete (or
> bio_check_pages_dirty for the aio case) so forcing the swapcache to be
> written out again before the page can be freed.

Do all the other get_user_pages() users do that, though?

[ Looks around - at least access_process_vm(), IB and the NFS direct code 
  do. So we seem to be mostly ok, at least for the main users ]

Ok, no worries.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
