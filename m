Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5EE6B03AA
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 04:03:47 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z1so15505142wrz.10
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 01:03:47 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id n30si16345007wrb.62.2017.06.21.01.03.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 21 Jun 2017 01:03:46 -0700 (PDT)
Date: Wed, 21 Jun 2017 10:03:41 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v3 03/11] x86/mm: Remove reset_lazy_tlbstate()
In-Reply-To: <3acc7ad02a2ec060d2321a1e0f6de1cb90069517.1498022414.git.luto@kernel.org>
Message-ID: <alpine.DEB.2.20.1706211003310.2328@nanos>
References: <cover.1498022414.git.luto@kernel.org> <3acc7ad02a2ec060d2321a1e0f6de1cb90069517.1498022414.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, 20 Jun 2017, Andy Lutomirski wrote:

> The only call site also calls idle_task_exit(), and idle_task_exit()
> puts us into a clean state by explicitly switching to init_mm.
> 
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Andy Lutomirski <luto@kernel.org>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
