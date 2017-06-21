Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id EFB9A6B03A6
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 04:02:05 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 77so14474193wrb.11
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 01:02:05 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id n100si17059296wrb.94.2017.06.21.01.02.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 21 Jun 2017 01:02:04 -0700 (PDT)
Date: Wed, 21 Jun 2017 10:01:51 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v3 01/11] x86/mm: Don't reenter flush_tlb_func_common()
In-Reply-To: <b13eee98a0e5322fbdc450f234a01006ec374e2c.1498022414.git.luto@kernel.org>
Message-ID: <alpine.DEB.2.20.1706211001330.2328@nanos>
References: <cover.1498022414.git.luto@kernel.org> <b13eee98a0e5322fbdc450f234a01006ec374e2c.1498022414.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, 20 Jun 2017, Andy Lutomirski wrote:
> Nadav noticed the reentrancy issue in a different context, but
> neither of us realized that it caused a problem yet.
> 
> Cc: Nadav Amit <nadav.amit@gmail.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Reported-by: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
> Fixes: 3d28ebceaffa ("x86/mm: Rework lazy TLB to track the actual loaded mm")
> Signed-off-by: Andy Lutomirski <luto@kernel.org>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
