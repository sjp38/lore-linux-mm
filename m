Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C0FAC6B029E
	for <linux-mm@kvack.org>; Tue, 15 May 2018 10:05:56 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id f23-v6so181950wra.20
        for <linux-mm@kvack.org>; Tue, 15 May 2018 07:05:56 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id q10-v6si447559edk.369.2018.05.15.07.05.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 May 2018 07:05:50 -0700 (PDT)
Date: Tue, 15 May 2018 16:05:49 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 2/3] x86/mm: add TLB purge to free pmd/pte page interfaces
Message-ID: <20180515140549.GE18595@8bytes.org>
References: <20180430175925.2657-1-toshi.kani@hpe.com>
 <20180430175925.2657-3-toshi.kani@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180430175925.2657-3-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: mhocko@suse.com, akpm@linux-foundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, cpandya@codeaurora.org, linux-mm@kvack.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Mon, Apr 30, 2018 at 11:59:24AM -0600, Toshi Kani wrote:
>  int pud_free_pmd_page(pud_t *pud, unsigned long addr)
>  {
> -	pmd_t *pmd;
> +	pmd_t *pmd, *pmd_sv;
> +	pte_t *pte;
>  	int i;
>  
>  	if (pud_none(*pud))
>  		return 1;
>  
>  	pmd = (pmd_t *)pud_page_vaddr(*pud);
> +	pmd_sv = (pmd_t *)__get_free_page(GFP_KERNEL);

So you need to allocate a page to free a page? It is better to put the
pages into a list with a list_head on the stack.

I am still on favour of just reverting the broken commit and do a
correct and working fix for the/a merge window.


	Joerg
