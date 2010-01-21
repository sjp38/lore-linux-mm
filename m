Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9BE3B6B007D
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 10:44:58 -0500 (EST)
Date: Thu, 21 Jan 2010 16:44:08 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 27 of 30] memcg compound
Message-ID: <20100121154408.GA5598@random.random>
References: <patchbomb.1264054824@v2.random>
 <2f3ecb53039bd9ae8c7a.1264054851@v2.random>
 <20100121160759.3dcad6ae.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100121160759.3dcad6ae.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 21, 2010 at 04:07:59PM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 21 Jan 2010 07:20:51 +0100
> Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > Teach memcg to charge/uncharge compound pages.
> > 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> 
> I'm sorry but I'm glad if you don't touch fast path.
> 
> if (likely(page_size == PAGE_SIZE))
> 	if (consume_stock(mem))
> 		goto charged;
> 
> is my recommendation.

Ok updated. But I didn't touch this code since last submit, because I
didn't merge the other patch (not yet in mainline) that you said would
complicate things. So I assume most if it will need to be rewritten. I
also though you wanted to remove the hpage size from the batch logic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
