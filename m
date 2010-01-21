Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 91BCC6B007D
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 18:58:53 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0LNwo6W020361
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 22 Jan 2010 08:58:51 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B6D1B45DE55
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 08:58:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 408EA45DE51
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 08:58:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 06C051DB803A
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 08:58:50 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CCE3E38002
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 08:58:48 +0900 (JST)
Date: Fri, 22 Jan 2010 08:55:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 27 of 30] memcg compound
Message-Id: <20100122085522.36a55b5c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100121154408.GA5598@random.random>
References: <patchbomb.1264054824@v2.random>
	<2f3ecb53039bd9ae8c7a.1264054851@v2.random>
	<20100121160759.3dcad6ae.kamezawa.hiroyu@jp.fujitsu.com>
	<20100121154408.GA5598@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 21 Jan 2010 16:44:08 +0100
Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Thu, Jan 21, 2010 at 04:07:59PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Thu, 21 Jan 2010 07:20:51 +0100
> > Andrea Arcangeli <aarcange@redhat.com> wrote:
> > 
> > > From: Andrea Arcangeli <aarcange@redhat.com>
> > > 
> > > Teach memcg to charge/uncharge compound pages.
> > > 
> > > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > I'm sorry but I'm glad if you don't touch fast path.
> > 
> > if (likely(page_size == PAGE_SIZE))
> > 	if (consume_stock(mem))
> > 		goto charged;
> > 
> > is my recommendation.
> 
> Ok updated. But I didn't touch this code since last submit, because I
> didn't merge the other patch (not yet in mainline) that you said would
> complicate things. So I assume most if it will need to be rewritten. I
> also though you wanted to remove the hpage size from the batch logic.
> 
I see. Thank you.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
