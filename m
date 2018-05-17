Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5384F6B0394
	for <linux-mm@kvack.org>; Thu, 17 May 2018 02:47:59 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 54-v6so2430682wrw.1
        for <linux-mm@kvack.org>; Wed, 16 May 2018 23:47:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 33-v6si3796709edr.332.2018.05.16.23.47.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 16 May 2018 23:47:57 -0700 (PDT)
Date: Thu, 17 May 2018 08:47:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 2/3] ioremap: Update pgtable free interfaces with addr
Message-ID: <20180517064755.GP12670@dhcp22.suse.cz>
References: <20180516233207.1580-1-toshi.kani@hpe.com>
 <20180516233207.1580-3-toshi.kani@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180516233207.1580-3-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: akpm@linux-foundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, cpandya@codeaurora.org, linux-mm@kvack.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Wed 16-05-18 17:32:06, Kani Toshimitsu wrote:
> From: Chintan Pandya <cpandya@codeaurora.org>
> 
> This patch ("mm/vmalloc: Add interfaces to free unmapped
> page table") adds following 2 interfaces to free the page
> table in case we implement huge mapping.
> 
> pud_free_pmd_page() and pmd_free_pte_page()
> 
> Some architectures (like arm64) needs to do proper TLB
> maintanance after updating pagetable entry even in map.
> Why ? Read this,
> https://patchwork.kernel.org/patch/10134581/

Please add that information to the changelog.
-- 
Michal Hocko
SUSE Labs
