Date: Mon, 23 Jun 2008 12:52:03 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: Can get_user_pages( ,write=1, force=1, ) result in a read-only
	pte and _count=2?
Message-ID: <20080623175203.GI10123@sgi.com>
References: <20080618164158.GC10062@sgi.com> <200806190329.30622.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0806181944080.4968@blonde.site> <200806191307.04499.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0806191154270.7324@blonde.site> <20080619133809.GC10123@sgi.com> <Pine.LNX.4.64.0806191441040.25832@blonde.site> <20080623155400.GH10123@sgi.com> <Pine.LNX.4.64.0806231718460.16782@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0806231718460.16782@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Robin Holt <holt@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 23, 2008 at 05:48:17PM +0100, Hugh Dickins wrote:
> On Mon, 23 Jun 2008, Robin Holt wrote:
> > All that said, I think the race we discussed earlier in the thread is
> > a legitimate one and believe Hugh's fix is correct.
> 
> My fix?  Would that be the get_user_pages VM_WRITE test before clearing
> FOLL_WRITE - which I believe didn't fix you at all?  Or the grand new

It did not fix the problem I was seeing, but I believe it is a possible
race condition.  I certainly admit to not having a complete enough
understanding and there may be something which prevents that from being
a problem, but I currently still think there is a problem, just not one
I can reproduce.

> reuse test in do_wp_page that I'm still working on - of which Nick sent
> a lock_page approximation for you to try?  Would you still be able to
> try mine when I'm ready, or does it now appear irrelevant to you?

Before your response, I had convinced myself my problem was specific to
XPMEM, but I see your point and may agree that it is a problem for all
get_user_pages() users.

I can certainly test when you have it ready.

I had confused myself about Nick's first patch.  I will give that
another look over and see if it fixes the problem.

> 	http://lkml.org/lkml/2006/9/14/384
> 
> but it's a broken thread, with misunderstanding on all sides,
> so rather hard to get a grasp of it.

That is extremely similar to the issue I am seeing.  I think that if
Infiniband were using the mmu_notifier stuff, they would be closer, but
IIRC, there are significant hardware restrictions which prevent demand
paging for working on some IB devices.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
