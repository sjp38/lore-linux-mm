Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8076FC0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 13:50:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0917821874
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 13:50:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0917821874
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80FD96B0003; Thu,  8 Aug 2019 09:50:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BF966B0006; Thu,  8 Aug 2019 09:50:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6AF366B0007; Thu,  8 Aug 2019 09:50:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1B0236B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 09:50:47 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id a5so58275607edx.12
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 06:50:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=tufBRt3P+EuxEuI2pjNG6+/RV3b6Ua59haN5tEaIpOM=;
        b=N7Ij3bgDEvyutCZ+FplOOGCBSJc3abBsdq1IUUU34Y2SeIAgRKRFmqtKoFPtU0vrYl
         pbdAwAynHrd19TUNG8RAEq4J5cv+hHd4unxl0hx9q/KwwHjLf4lGwoi5lp9Dr8vVOaYh
         QMd4V3yZNQmqz05sb5SC/mASe0aCYUdaJVqIOvx3m06K6Tob64D3B+jNZRK3kb0ySFda
         sERmrNjhbrSrJBHhpgp0ELJpw/W27dRK3e+YL+zXSm3ZsTFkyLorgYynA+VpIxi+64m5
         vKoPPrGJyHzCWxYn8PFu6PYKyFQIrpixcB7Tpk+AIgjrV0q0IndIHI4W9FJDIIAscCC4
         05NQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAUdl9LWC+YjN+hQoNv8BnE/hKbcOs97129JT3mBp1hp2gEzQ4Pm
	izNs/szETpCMeQ7c3AHPiEWaQ/KPEAYaRf1xX6sU5ognP+yMrcUAdBQp1oesihWaQnuGWWpzoT/
	xK822yD3ENXox2ZVFUNy0ZrKQGVgQevsVgoE+lU1Qp08UesmPtFFMwvKh17dpZPORCw==
X-Received: by 2002:a50:fb86:: with SMTP id e6mr15952384edq.203.1565272246557;
        Thu, 08 Aug 2019 06:50:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/8kNLrxwfj47hv0hlsuz+aIgc73+DHYMOZeoV84UliV32kbS3N8q8H7+1iKnXl0OrbeyS
X-Received: by 2002:a50:fb86:: with SMTP id e6mr15952280edq.203.1565272245512;
        Thu, 08 Aug 2019 06:50:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565272245; cv=none;
        d=google.com; s=arc-20160816;
        b=LwQ2NTGtvQe8zVhYbQ2HglgoL5fVagmoeKWdcxM4EWYuPdiHg8ug1nHoOlSaBLjEhV
         aw/fGdz4KCyvETM5n5EhzfmHN6hlg35r6Jz+uMC1CDeTbcH3CpUzzezL5k9ISo7FftQu
         Wto2NFY5ka38UV36ha0q/JqaWP73bfUhqpjPozREhds3O5FRSTv1nLk86CKaBO2Pw6Ds
         ARjei9L8R4Nvf0nAEgUyUigkY90jXwQSi+LIR2/njtGvZtFBG4Ez0P+QWngmX9I6vyla
         P+jqJ3Id20NkFMiGAQWYxb5eBaz4KMS+ShxPoqKgd1cFLdDmxHRqAJfk54om/B3BeBMb
         agsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=tufBRt3P+EuxEuI2pjNG6+/RV3b6Ua59haN5tEaIpOM=;
        b=jmsRG/WZgtVJEP702Y8CNZmE3PAIow8xR7f/uvr8hgT7g4m9k8a0JrIBQhRL8WTiOz
         DclJjbuaTocnFZAmwWZR01590OmJcArVYpu4JI9FSRQcSiEfSetmByPtj8bTrb8YDQIh
         YL5GnIp2cqsiMmbUTTJ4Xxjao5zIiHvZveQiQ3bSRu3bxOHRfMntutC3bsTZNa46O1sV
         OFVypkY+4Bm0lQPgR7NsUeABo80fY7URDsLWnXbypkD4Rlie89ObIDQGcq79EehE2mQV
         /V9AQM8phCRPxkIbmE23elVyfHT/yerv9A5zAjnRiM47BoFMVRYfToPlnLOT9D8wVMlq
         HILg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id r21si29345424ejz.133.2019.08.08.06.50.45
        for <linux-mm@kvack.org>;
        Thu, 08 Aug 2019 06:50:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 843FE15A2;
	Thu,  8 Aug 2019 06:50:44 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 4B4873F694;
	Thu,  8 Aug 2019 06:50:43 -0700 (PDT)
Date: Thu, 8 Aug 2019 14:50:37 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Daniel Axtens <dja@axtens.net>
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, x86@kernel.org,
	aryabinin@virtuozzo.com, glider@google.com, luto@kernel.org,
	linux-kernel@vger.kernel.org, dvyukov@google.com
Subject: Re: [PATCH v3 1/3] kasan: support backing vmalloc space with real
 shadow memory
Message-ID: <20190808135037.GA47131@lakrids.cambridge.arm.com>
References: <20190731071550.31814-1-dja@axtens.net>
 <20190731071550.31814-2-dja@axtens.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731071550.31814-2-dja@axtens.net>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Daniel,

This is looking really good!

I spotted a few more things we need to deal with, so I've suggested some
(not even compile-tested) code for that below. Mostly that's just error
handling, and using helpers to avoid things getting too verbose.

On Wed, Jul 31, 2019 at 05:15:48PM +1000, Daniel Axtens wrote:
> +void kasan_populate_vmalloc(unsigned long requested_size, struct vm_struct *area)
> +{
> +	unsigned long shadow_alloc_start, shadow_alloc_end;
> +	unsigned long addr;
> +	unsigned long page;
> +	pgd_t *pgdp;
> +	p4d_t *p4dp;
> +	pud_t *pudp;
> +	pmd_t *pmdp;
> +	pte_t *ptep;
> +	pte_t pte;
> +
> +	shadow_alloc_start = ALIGN_DOWN(
> +		(unsigned long)kasan_mem_to_shadow(area->addr),
> +		PAGE_SIZE);
> +	shadow_alloc_end = ALIGN(
> +		(unsigned long)kasan_mem_to_shadow(area->addr + area->size),
> +		PAGE_SIZE);
> +
> +	addr = shadow_alloc_start;
> +	do {
> +		pgdp = pgd_offset_k(addr);
> +		p4dp = p4d_alloc(&init_mm, pgdp, addr);
> +		pudp = pud_alloc(&init_mm, p4dp, addr);
> +		pmdp = pmd_alloc(&init_mm, pudp, addr);
> +		ptep = pte_alloc_kernel(pmdp, addr);
> +
> +		/*
> +		 * The pte may not be none if we allocated the page earlier to
> +		 * use part of it for another allocation.
> +		 *
> +		 * Because we only ever add to the vmalloc shadow pages and
> +		 * never free any, we can optimise here by checking for the pte
> +		 * presence outside the lock. It's OK to race with another
> +		 * allocation here because we do the 'real' test under the lock.
> +		 * This just allows us to save creating/freeing the new shadow
> +		 * page in the common case.
> +		 */
> +		if (!pte_none(*ptep))
> +			continue;
> +
> +		/*
> +		 * We're probably going to need to populate the shadow.
> +		 * Allocate and poision the shadow page now, outside the lock.
> +		 */
> +		page = __get_free_page(GFP_KERNEL);
> +		memset((void *)page, KASAN_VMALLOC_INVALID, PAGE_SIZE);
> +		pte = pfn_pte(PFN_DOWN(__pa(page)), PAGE_KERNEL);
> +
> +		spin_lock(&init_mm.page_table_lock);
> +		if (pte_none(*ptep)) {
> +			set_pte_at(&init_mm, addr, ptep, pte);
> +			page = 0;
> +		}
> +		spin_unlock(&init_mm.page_table_lock);
> +
> +		/* catch the case where we raced and don't need the page */
> +		if (page)
> +			free_page(page);
> +	} while (addr += PAGE_SIZE, addr != shadow_alloc_end);
> +

From looking at this for a while, there are a few more things we should
sort out:

* We need to handle allocations failing. I think we can get most of that
  by using apply_to_page_range() to allocate the tables for us.

* Between poisoning the page and updating the page table, we need an
  smp_wmb() to ensure that the poison is visible to other CPUs, similar
  to what __pte_alloc() and friends do when allocating new tables.

* We can use the split pmd locks (used by both x86 and arm64) to
  minimize contention on the init_mm ptl. As apply_to_page_range()
  doesn't pass the corresponding pmd in, we'll have to re-walk the table
  in the callback, but I suspect that's better than having all vmalloc
  operations contend on the same ptl.

I think it would make sense to follow the style of the __alloc_p??
functions and factor out the actual initialization into a helper like:

static int __kasan_populate_vmalloc_pte(pmd_t *pmdp, pte_t *ptep)
{
	unsigned long page;
	spinlock_t *ptl;
	pte_t pte;

	page = __get_free_page(GFP_KERNEL);
	if (!page)
		return -ENOMEM;

	memset((void *)page, KASAN_VMALLOC_INVALID, PAGE_SIZE);
	pte = pfn_pte(page_to_pfn(page), PAGE_KERNEL);

	/*
	 * Ensure poisoning is visible before the shadow is made visible
	 * to other CPUs.
	 */
	smp_wmb();
	
	ptl = pmd_lock(&init_mm, pmdp);
	if (likely(pte_none(*ptep))) {
		set_pte(ptep, pte)
		page = 0;
	}
	spin_unlock(ptl);
	if (page)
		free_page(page);
	return 0;
}

... with the apply_to_page_range() callback looking a bit like
alloc_p??(), grabbing the pmd for its ptl.

static int kasan_populate_vmalloc_pte(pte_t *ptep, unsigned long addr, void *unused)
{
	pgd_t *pgdp;
	p4d_t *p4dp;
	pud_t *pudp;
	pmd_t *pmdp;

	if (likely(!pte_none(*ptep)))
		return 0;

	pgdp = pgd_offset_k(addr);
	p4dp = p4d_offset(pgdp, addr)
	pudp = pud_pffset(p4dp, addr);
	pmdp = pmd_offset(pudp, addr);

	return __kasan_populate_vmalloc_pte(pmdp, ptep);
}

... and the main function looking something like:

int kasan_populate_vmalloc(...)
{
	unsigned long shadow_start, shadow_size;
	unsigned long addr;
	int ret;

	// calculate shadow bounds here
	
	ret = apply_to_page_range(&init_mm, shadow_start, shadow_size,
				  kasan_populate_vmalloc_pte, NULL);
	if (ret)
		return ret;
	
	...

	// unpoison the new allocation here
}

> +	kasan_unpoison_shadow(area->addr, requested_size);
> +
> +	/*
> +	 * We have to poison the remainder of the allocation each time, not
> +	 * just when the shadow page is first allocated, because vmalloc may
> +	 * reuse addresses, and an early large allocation would cause us to
> +	 * miss OOBs in future smaller allocations.
> +	 *
> +	 * The alternative is to poison the shadow on vfree()/vunmap(). We
> +	 * don't because the unmapping the virtual addresses should be
> +	 * sufficient to find most UAFs.
> +	 */
> +	requested_size = round_up(requested_size, KASAN_SHADOW_SCALE_SIZE);
> +	kasan_poison_shadow(area->addr + requested_size,
> +			    area->size - requested_size,
> +			    KASAN_VMALLOC_INVALID);
> +}

Is it painful to do the unpoison in the vfree/vunmap paths? I haven't
looked, so I might have missed something that makes that nasty.

If it's possible, I think it would be preferable to do so. It would be
consistent with the non-vmalloc KASAN cases. IIUC in that case we only
need the requested size here (and not the vmap_area), so we could just
take start and size as arguments.

Thanks,
Mark.

