Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id m7GHbs2T188068
	for <linux-mm@kvack.org>; Sat, 16 Aug 2008 17:37:54 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7GHbrQF1806372
	for <linux-mm@kvack.org>; Sat, 16 Aug 2008 19:37:53 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7GHbrhf003763
	for <linux-mm@kvack.org>; Sat, 16 Aug 2008 19:37:53 +0200
Subject: Re: [PATCH] mm: page_remove_rmap comments on PageAnon
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <Pine.LNX.4.64.0808152146220.7958@blonde.site>
References: <Pine.LNX.4.64.0808152146220.7958@blonde.site>
Content-Type: text/plain
Date: Sat, 16 Aug 2008 19:37:50 +0200
Message-Id: <1218908270.6037.2.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-08-15 at 21:49 +0100, Hugh Dickins wrote:
> Add a comment to s390's page_test_dirty/page_clear_dirty/page_set_dirty
> dance in page_remove_rmap(): I was wrong to think the PageSwapCache test
> could be avoided, and would like a comment in there to remind me.  And
> mention s390, to help us remember that this block is not really common.
> 
> Also move down the "It would be tidy to reset PageAnon" comment: it does
> not belong to s390's block, and it would be unwise to reset PageAnon
> before we're done with testing it.

Looks fine to me. Thanks Hugh. And if anybody cares:

Acked-by: Martin Schwidefsky <schwidefsky@de.ibm.com>

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
