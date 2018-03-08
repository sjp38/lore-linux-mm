Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5307B6B0003
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 23:00:52 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id l1so1901668pga.1
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 20:00:52 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v10-v6si14151591plo.61.2018.03.07.20.00.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Mar 2018 20:00:51 -0800 (PST)
Date: Wed, 7 Mar 2018 20:00:16 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/2] mm/vmalloc: Add interfaces to free unused page table
Message-ID: <20180308040016.GB9082@bombadil.infradead.org>
References: <20180307183227.17983-1-toshi.kani@hpe.com>
 <20180307183227.17983-2-toshi.kani@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180307183227.17983-2-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: mhocko@suse.com, akpm@linux-foundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, bp@suse.de, catalin.marinas@arm.com, guohanjun@huawei.com, will.deacon@arm.com, wxf.wang@hisilicon.com, linux-mm@kvack.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org

On Wed, Mar 07, 2018 at 11:32:26AM -0700, Toshi Kani wrote:
> +/**
> + * pud_free_pmd_page - clear pud entry and free pmd page
> + *
> + * Returns 1 on success and 0 on failure (pud not cleared).
> + */
> +int pud_free_pmd_page(pud_t *pud)
> +{
> +	return pud_none(*pud);
> +}

Wouldn't it be clearer if you returned 'bool' instead of 'int' here?

Also you didn't document the pud parameter, nor use the approved form
for documenting the return type, nor the calling context.  So I would
have written it out like this:

/**
 * pud_free_pmd_page - Clear pud entry and free pmd page.
 * @pud: Pointer to a PUD.
 *
 * Context: Caller should hold mmap_sem write-locked.
 * Return: %true if clearing the entry succeeded.
 */
