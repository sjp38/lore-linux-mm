Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7B7FF6B03AB
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 04:06:01 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z81so3517093wrc.2
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 01:06:01 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 62si5096563wrg.61.2017.06.21.01.06.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 21 Jun 2017 01:06:00 -0700 (PDT)
Date: Wed, 21 Jun 2017 10:05:55 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v3 04/11] x86/mm: Give each mm TLB flush generation a
 unique ID
In-Reply-To: <e2903f555bd23f8cf62f34b91895c42f7d4e40e3.1498022414.git.luto@kernel.org>
Message-ID: <alpine.DEB.2.20.1706211005270.2328@nanos>
References: <cover.1498022414.git.luto@kernel.org> <e2903f555bd23f8cf62f34b91895c42f7d4e40e3.1498022414.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, 20 Jun 2017, Andy Lutomirski wrote:

> This adds two new variables to mmu_context_t: ctx_id and tlb_gen.
> ctx_id uniquely identifies the mm_struct and will never be reused.
> For a given mm_struct (and hence ctx_id), tlb_gen is a monotonic
> count of the number of times that a TLB flush has been requested.
> The pair (ctx_id, tlb_gen) can be used as an identifier for TLB
> flush actions and will be used in subsequent patches to reliably
> determine whether all needed TLB flushes have occurred on a given
> CPU.
> 
> This patch is split out for ease of review.  By itself, it has no
> real effect other than creating and updating the new variables.

Thanks for splitting this apart!

> 
> Signed-off-by: Andy Lutomirski <luto@kernel.org>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
