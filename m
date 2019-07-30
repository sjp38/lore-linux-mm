Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A81FC0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 08:38:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E688F206A2
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 08:38:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="fBVA+CF5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E688F206A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BE848E0003; Tue, 30 Jul 2019 04:38:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 796758E0001; Tue, 30 Jul 2019 04:38:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 684F28E0003; Tue, 30 Jul 2019 04:38:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 35DDE8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 04:38:54 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id u1so40109374pgr.13
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:38:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:in-reply-to
         :references:date:message-id:mime-version;
        bh=xAWml8zHr+RR4WtcfJXF5qLyW4vcoY8hdC2IB6AOcOc=;
        b=c93iMVqV7Mh3Jg4I1pkgfIfUZoz5MONU/1nbsGWImGt9oWZ5PntHv6pS+UZskRE5EE
         ZyTV98DzRSSPnfrO8EMNtS0zwP21FfjqcqnYoZulafOZ8PYVDNS8i+bpL58E0Sxa7E92
         FraZ0JpZVPgOnbgigLcBkf8p/Wq8cBS/6cjPrPUdOBI3lktxgwvSZDOKdkIPa84rkq6M
         0IdSs2sEJciAJyLsR5ZxpvuBi3A07yHxFXYXoCbumW0sUqVQ08MA6dIZn3Lp0+fCCJse
         m+VCc4Y6M7NFWZ28sOVSPetIRxV+s/JJUI2WCUAZgaJPhJdb9ROKrTJrlOqeIyuCWhhi
         Oq6A==
X-Gm-Message-State: APjAAAXJeQdiq+sPTDj+TEGHBJMIevZHJToHGrPqDB/WLDDl46q2HjZZ
	hoPADpNSJSf4VqN3fJBKsqdgk1Gek3BaTIM2/g0Yme6XevCCP2nWlJMBjJsCniAjYj6Wy6LBCzl
	v4U3cxJPaPs1EyWr2gnm/OiGdChgRn4YTX5d36DnaAVwl6OFTRz2CLeGZ0MzLPVBKjQ==
X-Received: by 2002:a17:902:ff10:: with SMTP id f16mr19306196plj.141.1564475933814;
        Tue, 30 Jul 2019 01:38:53 -0700 (PDT)
X-Received: by 2002:a17:902:ff10:: with SMTP id f16mr19306155plj.141.1564475933009;
        Tue, 30 Jul 2019 01:38:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564475933; cv=none;
        d=google.com; s=arc-20160816;
        b=G3JEzWJUEwAjAMlBXYUDuhSEAD761Yvq/dL9QZi54ylB2OEtthyQmvw+aKbCtpvctC
         Mxy03yMYpni3Uw7oWZwyDS0sT7k1mfz4CExUBGDuEjxIkSXFhEzdeyrTnz3z8O/6HwvZ
         3wLM3tma12PIFhrDRKT1Z505CGRDspDO8zqu5aDKd60Coa1D/8XxC+knxTLEOoL9jY/M
         +wXRZmT+FW7OOaM1duRv9rsmeSVSce4n7FMNGJ3OLO1JM6uPappR0KppCBbUjBBBF0Rg
         v/MewQ8/6ckcKk09/pkXRWKqyT9OfNgXu6G8IttEq1sJoehmQfWSrpAKIfht/ZdK5tiH
         M3ig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from:dkim-signature;
        bh=xAWml8zHr+RR4WtcfJXF5qLyW4vcoY8hdC2IB6AOcOc=;
        b=i3iA7IGYTOIDdWHpc9SFoqWkaoG2blUUuBqgRr+EOUE2RbpBGu+WwAy8sMAeG2mKV5
         WW4WuKJKzD2jjIhGATDN4+dHnoVdHioII3U7T/bn77JPsuf4rUH5hoLDECXnVeTiMXIL
         ajOoHSvqycwF00FHDOu5MoZAH/2nib1j69xXh4+b1M2xreA1B4qej256m0oXRXMgKpyv
         koGbhhBHDZMIY5W6jmyPRQ+wiMvBV4L1nV/HTxUxT19Wv19hwOAFWa8RVd36Z5TRFw4y
         J8LJAE3S3ZD0dD+D55pylcqoRJ5JHRiEsXUlnerjFhn9syc9uZUXPJFambMlh+WbT8Ef
         5TZw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=fBVA+CF5;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g71sor75551846pje.16.2019.07.30.01.38.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jul 2019 01:38:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=fBVA+CF5;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:in-reply-to:references:date:message-id
         :mime-version;
        bh=xAWml8zHr+RR4WtcfJXF5qLyW4vcoY8hdC2IB6AOcOc=;
        b=fBVA+CF5JEE+effJV4K3mQ0bjdRf0WrTxicmyOKsFjrrZqG78elCDi+wOBnBnXbWx4
         ym1k2k4QFEQUs+2gBa3CJ8E3EZlJB6wKi6b2qJAHGQoVrmG3TXgEof609/nKFxHb+7dJ
         eMDWK3XSTFbb8nqVxKtVIsKD6qfgbXSrkfehk=
X-Google-Smtp-Source: APXvYqwSLszFoXT/40dnLzTLf7YGDHfpuGGatDiw5WyLEl3Fheu3QtT1c4tQCU0jbRE9fZcIOn3FmQ==
X-Received: by 2002:a17:90a:17c4:: with SMTP id q62mr117904140pja.104.1564475932272;
        Tue, 30 Jul 2019 01:38:52 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id q126sm70680998pfq.123.2019.07.30.01.38.50
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 30 Jul 2019 01:38:51 -0700 (PDT)
From: Daniel Axtens <dja@axtens.net>
To: Mark Rutland <mark.rutland@arm.com>
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, x86@kernel.org, aryabinin@virtuozzo.com, glider@google.com, luto@kernel.org, linux-kernel@vger.kernel.org, dvyukov@google.com
Subject: Re: [PATCH v2 1/3] kasan: support backing vmalloc space with real shadow memory
In-Reply-To: <20190729154426.GA51922@lakrids.cambridge.arm.com>
References: <20190729142108.23343-1-dja@axtens.net> <20190729142108.23343-2-dja@axtens.net> <20190729154426.GA51922@lakrids.cambridge.arm.com>
Date: Tue, 30 Jul 2019 18:38:47 +1000
Message-ID: <877e7zhq7c.fsf@dja-thinkpad.axtens.net>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Mark,

Thanks for your email - I'm very new to mm stuff and the feedback is
very helpful.

>> +#ifndef CONFIG_KASAN_VMALLOC
>>  int kasan_module_alloc(void *addr, size_t size)
>>  {
>>  	void *ret;
>> @@ -603,6 +604,7 @@ void kasan_free_shadow(const struct vm_struct *vm)
>>  	if (vm->flags & VM_KASAN)
>>  		vfree(kasan_mem_to_shadow(vm->addr));
>>  }
>> +#endif
>
> IIUC we can drop MODULE_ALIGN back to PAGE_SIZE in this case, too.

Yes, done.

>>  core_initcall(kasan_memhotplug_init);
>>  #endif
>> +
>> +#ifdef CONFIG_KASAN_VMALLOC
>> +void kasan_cover_vmalloc(unsigned long requested_size, struct vm_struct *area)
>
> Nit: I think it would be more consistent to call this
> kasan_populate_vmalloc().
>

Absolutely. I didn't love the name but just didn't 'click' that populate
would be a better verb.

>> +{
>> +	unsigned long shadow_alloc_start, shadow_alloc_end;
>> +	unsigned long addr;
>> +	unsigned long backing;
>> +	pgd_t *pgdp;
>> +	p4d_t *p4dp;
>> +	pud_t *pudp;
>> +	pmd_t *pmdp;
>> +	pte_t *ptep;
>> +	pte_t backing_pte;
>
> Nit: I think it would be preferable to use 'page' rather than 'backing',
> and 'pte' rather than 'backing_pte', since there's no otehr namespace to
> collide with here. Otherwise, using 'shadow' rather than 'backing' would
> be consistent with the existing kasan code.

Not a problem, done.

>> +	addr = shadow_alloc_start;
>> +	do {
>> +		pgdp = pgd_offset_k(addr);
>> +		p4dp = p4d_alloc(&init_mm, pgdp, addr);
>> +		pudp = pud_alloc(&init_mm, p4dp, addr);
>> +		pmdp = pmd_alloc(&init_mm, pudp, addr);
>> +		ptep = pte_alloc_kernel(pmdp, addr);
>> +
>> +		/*
>> +		 * we can validly get here if pte is not none: it means we
>> +		 * allocated this page earlier to use part of it for another
>> +		 * allocation
>> +		 */
>> +		if (pte_none(*ptep)) {
>> +			backing = __get_free_page(GFP_KERNEL);
>> +			backing_pte = pfn_pte(PFN_DOWN(__pa(backing)),
>> +					      PAGE_KERNEL);
>> +			set_pte_at(&init_mm, addr, ptep, backing_pte);
>> +		}
>
> Does anything prevent two threads from racing to allocate the same
> shadow page?
>
> AFAICT it's possible for two threads to get down to the ptep, then both
> see pte_none(*ptep)), then both try to allocate the same page.
>
> I suspect we have to take init_mm::page_table_lock when plumbing this
> in, similarly to __pte_alloc().

Good catch. I think you're right, I'll add the lock.

>> +	} while (addr += PAGE_SIZE, addr != shadow_alloc_end);
>> +
>> +	kasan_unpoison_shadow(area->addr, requested_size);
>> +	requested_size = round_up(requested_size, KASAN_SHADOW_SCALE_SIZE);
>> +	kasan_poison_shadow(area->addr + requested_size,
>> +			    area->size - requested_size,
>> +			    KASAN_VMALLOC_INVALID);
>
> IIUC, this could leave the final portion of an allocated page
> unpoisoned.
>
> I think it might make more sense to poison each page when it's
> allocated, then plumb it into the page tables, then unpoison the object.
>
> That way, we can rely on any shadow allocated by another thread having
> been initialized to KASAN_VMALLOC_INVALID, and only need mutual
> exclusion when allocating the shadow, rather than when poisoning
> objects.

Yes, that makes sense, will do.

Thanks again,
Daniel

