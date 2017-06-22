Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D12EF6B02B4
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 12:10:07 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u8so19471857pgo.11
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 09:10:07 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id a59si1481302plc.356.2017.06.22.09.10.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 09:10:07 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id d5so3641404pfe.1
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 09:10:06 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH v3 11/11] x86/mm: Try to preserve old TLB entries using
 PCID
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <a8cdfbbb17785aed10980d24692745f68615a584.1498022414.git.luto@kernel.org>
Date: Thu, 22 Jun 2017 09:09:56 -0700
Content-Transfer-Encoding: 7bit
Message-Id: <E43BCF62-8688-4238-80F6-FE6F0040FD25@gmail.com>
References: <cover.1498022414.git.luto@kernel.org>
 <cover.1498022414.git.luto@kernel.org>
 <a8cdfbbb17785aed10980d24692745f68615a584.1498022414.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

Andy Lutomirski <luto@kernel.org> wrote:

> 
> --- a/arch/x86/mm/init.c
> +++ b/arch/x86/mm/init.c
> @@ -812,6 +812,7 @@ void __init zone_sizes_init(void)
> 
> DEFINE_PER_CPU_SHARED_ALIGNED(struct tlb_state, cpu_tlbstate) = {
> 	.loaded_mm = &init_mm,
> +	.next_asid = 1,

I think this is a remainder from previous version of the patches, no? It
does not seem necessary and may be confusing (ctx_id 0 is reserved, but not
asid 0).

Other than that, if you want, you can put for the entire series:

Reviewed-by: Nadav Amit <nadav.amit@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
