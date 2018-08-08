Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 115516B0003
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 10:26:29 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id a23-v6so1450441pfo.23
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 07:26:29 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id p15-v6si4414740pgh.281.2018.08.08.07.26.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 08 Aug 2018 07:26:27 -0700 (PDT)
In-Reply-To: <20180727114817.27190-1-npiggin@gmail.com>
From: Michael Ellerman <patch-notifications@ellerman.id.au>
Subject: Re: [resend] powerpc/64s: fix page table fragment refcount race vs speculative references
Message-Id: <41ltwv4RJjz9s4V@ozlabs.org>
Date: Thu,  9 Aug 2018 00:26:10 +1000 (AEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>, linuxppc-dev@lists.ozlabs.org
Cc: "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

On Fri, 2018-07-27 at 11:48:17 UTC, Nicholas Piggin wrote:
> The page table fragment allocator uses the main page refcount racily
> with respect to speculative references. A customer observed a BUG due
> to page table page refcount underflow in the fragment allocator. This
> can be caused by the fragment allocator set_page_count stomping on a
> speculative reference, and then the speculative failure handler
> decrements the new reference, and the underflow eventually pops when
> the page tables are freed.
> 
> Fix this by using a dedicated field in the struct page for the page
> table fragment allocator.
> 
> Fixes: 5c1f6ee9a31c ("powerpc: Reduce PTE table memory wastage")
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> Signed-off-by: Nicholas Piggin <npiggin@gmail.com>

Applied to powerpc next, thanks.

https://git.kernel.org/powerpc/c/4231aba000f5a4583dd9f67057aadb

cheers
