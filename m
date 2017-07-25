Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7327D6B0292
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 06:02:49 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id c196so62153937itc.2
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 03:02:49 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id k82si1477406itb.186.2017.07.25.03.02.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 03:02:48 -0700 (PDT)
Date: Tue, 25 Jul 2017 12:02:34 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v5 2/2] x86/mm: Improve TLB flush documentation
Message-ID: <20170725100234.qbsuphozotivan3c@hirez.programming.kicks-ass.net>
References: <cover.1500957502.git.luto@kernel.org>
 <695299daa67239284e8db5a60d4d7eb88c914e0a.1500957502.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <695299daa67239284e8db5a60d4d7eb88c914e0a.1500957502.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>

On Mon, Jul 24, 2017 at 09:41:39PM -0700, Andy Lutomirski wrote:
> +		/*
> +		 * Resume remote flushes and then read tlb_gen.  The
> +		 * implied barrier in atomic64_read() synchronizes

There is no barrier in atomic64_read().

> +		 * with inc_mm_tlb_gen() like this:
> +		 *
> +		 * switch_mm_irqs_off():	flush request:
> +		 *  cpumask_set_cpu(...);	 inc_mm_tlb_gen();
> +		 *  MB				 MB
> +		 *  atomic64_read(.tlb_gen);	 flush_tlb_others(mm_cpumask());
> +		 */
>  		cpumask_set_cpu(cpu, mm_cpumask(next));
>  		next_tlb_gen = atomic64_read(&next->context.tlb_gen);
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
