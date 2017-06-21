Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8AEDC6B03A8
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 04:03:19 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 64so21452614wrp.4
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 01:03:19 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 90si10054787wre.227.2017.06.21.01.03.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 21 Jun 2017 01:03:18 -0700 (PDT)
Date: Wed, 21 Jun 2017 10:03:14 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v3 02/11] x86/ldt: Simplify LDT switching logic
In-Reply-To: <2a859ac01245f9594c58f9d0a8b2ed8a7cd2507e.1498022414.git.luto@kernel.org>
Message-ID: <alpine.DEB.2.20.1706211002590.2328@nanos>
References: <cover.1498022414.git.luto@kernel.org> <2a859ac01245f9594c58f9d0a8b2ed8a7cd2507e.1498022414.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, 20 Jun 2017, Andy Lutomirski wrote:
> When we redo lazy mode to stop flush IPIs without switching to
> init_mm, though, the current logic would become incorrect: it will
> be possible to have real_prev == next but nonetheless have a stale
> LDT descriptor.
> 
> Simplify the code to update LDTR if either the previous or the next
> mm has an LDT, i.e. effectively restore the historical logic..
> While we're at it, clean up the code by moving all the ifdeffery to
> a header where it belongs.
> 
> Acked-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Andy Lutomirski <luto@kernel.org>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
