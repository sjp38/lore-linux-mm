Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35647C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 21:10:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDCD72077B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 21:10:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDCD72077B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F72B8E0005; Tue, 12 Mar 2019 17:10:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A4698E0002; Tue, 12 Mar 2019 17:10:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 493B68E0005; Tue, 12 Mar 2019 17:10:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 03B858E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 17:10:12 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id v2so3955442pfn.14
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 14:10:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WHoBSpazQxbTj5zzDQc+0xfXtDWfyvD2aJzrJ7gW3Uc=;
        b=ghpMw4YihoH5tChU31fDqFK4+rpCUGqvNCAvBmaDnv5A+LRAlg766YJHMu162qUAyY
         Vq2IJniOGFRwmvvsd8veF7s59ZTXwYd+yGfRjMGRLXbYj56wUPm16y68OY/w2FkWQq7b
         Pfy4PMFJkjhQO1BjeMwYnbhYJsCxz5w3T46Luc2WbEymMVL2g4G0QyHxZJHSjsF7oOy7
         IlnVwMKjlr+KxT726vWiGehb3l4vL/L5Mz7ceLWvkONJJbjnZO5+IxH7J7tAo9ikTQMM
         QnM/6DwnMZbPjdsGgTV40wl6evRQ5Uwk4KT2OK/zFvGg8PMf/0X3dhYrSHEaitMrSSlM
         D5+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAUfDsqlYy0Al4JdcYd2Es9wqTi0O/eWUoEwYvVWTMqQTYyF61A0
	Qz93Wboj+fIBUEvE9y39Xv7N/1bfLHUBf3FU/9vUrpumjfRUMsASbgm4Qeucrb0Yn1Ij6N+4NpL
	V3uPCgKFrZT7em6TOMWe633ewvpgUr2d0+AIYDWxouF8S2GDPRvP5IbE79Mh/e2c9uQ==
X-Received: by 2002:a17:902:2ba7:: with SMTP id l36mr19956307plb.246.1552425011439;
        Tue, 12 Mar 2019 14:10:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWGewktN4+75w17qtNEYmZirZmmeqqi6xWQhaX2XpQH/IQ935t6fR5WOSN3MTTfnEHjq5p
X-Received: by 2002:a17:902:2ba7:: with SMTP id l36mr19956248plb.246.1552425010434;
        Tue, 12 Mar 2019 14:10:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552425010; cv=none;
        d=google.com; s=arc-20160816;
        b=HGdvAfejsuYwh6F7tPkyGDhnVr1N5okad8LanvgUh86XAsM3mvYdovQ39QB5GARVul
         VdcgzolcE57QFATmI1GdlhvlJejjTxPbxKGsaXYhQCLibdoa/OeIvb6z+nvKzJ6MXNjy
         QFUjCKHdM0GnUZG/EF90f+/FL4DXvSgExGus3ks509nUg1IXIwktX09uS7qj/Y1D3lY0
         FMYGWDRgtCiC5zsaSCGDvxe4orlzi1VakUCQZ7qPB/kMsA6C2x6xREY5O9cDqgZpDXpP
         Ww16Og3Cor5M3+WatmITAND2lea1tv0reLed6TNlpKBdOgaKyJYapUNnFwqQY6Latq8q
         VuCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=WHoBSpazQxbTj5zzDQc+0xfXtDWfyvD2aJzrJ7gW3Uc=;
        b=j6UKpauISpG+n/ffwTWfitF8Wh3FNPt4ld7u5MVvPUPNZ8xBlmVZHl91JU/grUaZVT
         ntGI+nnDrMpat+E1dVYanD8tqWs+jWeyYUsgk/UZ/hMyQHS2YPAvdZrsawLWiMCDdDtx
         A8e0i+8t9vjqboOvPf9S1nIiJ88WKlvaTjBVD7/qIJr32F26H1Az0305sJKshDwyyHyJ
         V0+MRBGI9gYtP38OwDDXvtnyjTkornwSHS28cOOorkogruBQ83fWL6NFtOq92W5eJv03
         xVi2CaagZqGGjX27ZaGPCsE3JK7TdkkLlxKStTOiDRp9Gy5NG/SOHT8EZW+kEI0uDu/P
         zktg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i39si9350864plb.210.2019.03.12.14.10.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 14:10:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id CCA49E3C;
	Tue, 12 Mar 2019 21:10:09 +0000 (UTC)
Date: Tue, 12 Mar 2019 14:10:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Qian Cai <cai@lca.pw>
Cc: catalin.marinas@arm.com, agraf@suse.de, paulus@ozlabs.org,
 benh@kernel.crashing.org, pe@ellerman.id.au, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, kvm-ppc@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH] kmemleak: skip scanning holes in the .bss section
Message-Id: <20190312141008.39eca5a0f03aaf2b86178ae9@linux-foundation.org>
In-Reply-To: <20190312191412.28656-1-cai@lca.pw>
References: <20190312191412.28656-1-cai@lca.pw>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Mar 2019 15:14:12 -0400 Qian Cai <cai@lca.pw> wrote:

> The commit 2d4f567103ff ("KVM: PPC: Introduce kvm_tmp framework") adds
> kvm_tmp[] into the .bss section and then free the rest of unused spaces
> back to the page allocator.
> 
> kernel_init
>   kvm_guest_init
>     kvm_free_tmp
>       free_reserved_area
>         free_unref_page
>           free_unref_page_prepare
> 
> With DEBUG_PAGEALLOC=y, it will unmap those pages from kernel. As the
> result, kmemleak scan will trigger a panic below when it scans the .bss
> section with unmapped pages.
> 
> Since this is done way before the first kmemleak_scan(), just go
> lockless to make the implementation simple and skip those pages when
> scanning the .bss section. Later, those pages could be tracked by
> kmemleak again once allocated by the page allocator. Overall, this is
> such a special case, so no need to make it a generic to let kmemleak
> gain an ability to skip blocks in scan_large_block().
> 
> BUG: Unable to handle kernel data access at 0xc000000001610000
> Faulting instruction address: 0xc0000000003cc178
> Oops: Kernel access of bad area, sig: 11 [#1]
> LE PAGE_SIZE=64K MMU=Hash SMP NR_CPUS=256 DEBUG_PAGEALLOC NUMA pSeries
> CPU: 3 PID: 130 Comm: kmemleak Kdump: loaded Not tainted 5.0.0+ #9
> REGS: c0000004b05bf940 TRAP: 0300   Not tainted  (5.0.0+)
> NIP [c0000000003cc178] scan_block+0xa8/0x190
> LR [c0000000003cc170] scan_block+0xa0/0x190
> Call Trace:
> [c0000004b05bfbd0] [c0000000003cc170] scan_block+0xa0/0x190 (unreliable)
> [c0000004b05bfc30] [c0000000003cc2c0] scan_large_block+0x60/0xa0
> [c0000004b05bfc70] [c0000000003ccc64] kmemleak_scan+0x254/0x960
> [c0000004b05bfd40] [c0000000003cdd50] kmemleak_scan_thread+0xec/0x12c
> [c0000004b05bfdb0] [c000000000104388] kthread+0x1b8/0x1c0
> [c0000004b05bfe20] [c00000000000b364] ret_from_kernel_thread+0x5c/0x78
> Instruction dump:
> 7fa3eb78 4844667d 60000000 60000000 60000000 60000000 3bff0008 7fbcf840
> 409d00b8 4bfffeed 2fa30000 409e00ac <e87f0000> e93e0128 7fa91840
> 419dffdc
> 

hm, yes, this is super crude.  I guess we can turn it into something
more sophisticated if another caller is identified.

> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -237,6 +237,10 @@ static int kmemleak_skip_disable;
>  /* If there are leaks that can be reported */
>  static bool kmemleak_found_leaks;
>  
> +/* Skip scanning of a range in the .bss section. */
> +static void *bss_hole_start;
> +static void *bss_hole_stop;
> +
>  static bool kmemleak_verbose;
>  module_param_named(verbose, kmemleak_verbose, bool, 0600);
>  
> @@ -1265,6 +1269,18 @@ void __ref kmemleak_ignore_phys(phys_addr_t phys)
>  }
>  EXPORT_SYMBOL(kmemleak_ignore_phys);
>  
> +/**
> + * kmemleak_bss_hole - skip scanning a range in the .bss section
> + *
> + * @start:	start of the range
> + * @stop:	end of the range
> + */
> +void kmemleak_bss_hole(void *start, void *stop)
> +{
> +	bss_hole_start = start;
> +	bss_hole_stop = stop;
> +}

I'll make this __init.

>  /*
>   * Update an object's checksum and return true if it was modified.
>   */
> @@ -1531,7 +1547,14 @@ static void kmemleak_scan(void)
>  
>  	/* data/bss scanning */
>  	scan_large_block(_sdata, _edata);
> -	scan_large_block(__bss_start, __bss_stop);
> +
> +	if (bss_hole_start) {
> +		scan_large_block(__bss_start, bss_hole_start);
> +		scan_large_block(bss_hole_stop, __bss_stop);
> +	} else {
> +		scan_large_block(__bss_start, __bss_stop);
> +	}
> +
>  	scan_large_block(__start_ro_after_init, __end_ro_after_init);
>  
>  #ifdef CONFIG_SMP

