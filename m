Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94CECC41514
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 14:32:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4AEDC21670
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 14:32:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="OwysBwWB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4AEDC21670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EECB56B0007; Mon,  2 Sep 2019 10:32:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E9DD46B0008; Mon,  2 Sep 2019 10:32:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB3CA6B000A; Mon,  2 Sep 2019 10:32:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0109.hostedemail.com [216.40.44.109])
	by kanga.kvack.org (Postfix) with ESMTP id BB27B6B0007
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 10:32:55 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 5FC42180AD801
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 14:32:55 +0000 (UTC)
X-FDA: 75890222310.05.cakes52_70be8ba015d61
X-HE-Tag: cakes52_70be8ba015d61
X-Filterd-Recvd-Size: 6661
Received: from mail-pg1-f196.google.com (mail-pg1-f196.google.com [209.85.215.196])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 14:32:54 +0000 (UTC)
Received: by mail-pg1-f196.google.com with SMTP id i18so7547524pgl.11
        for <linux-mm@kvack.org>; Mon, 02 Sep 2019 07:32:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:in-reply-to:references:date:message-id
         :mime-version;
        bh=7KTrdItVhsmDUyDggdvNWAkcifUfR9oLU9QTC4MXwVE=;
        b=OwysBwWBhAFJooEe68fXdIvv4V+cnKggsrlbqAeXs+dqEcl+QhGbcO5oMMRvzRoGRC
         7iS0t1CjmmNIOidW8RdA+pFVSb6cK4kr0eVSanNg4sE49DePUje7xpSa/T9xkUG38qOn
         SaWaorLUSS7vNGVB86NunS287AAXQBvgjmjWc=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:in-reply-to:references:date
         :message-id:mime-version;
        bh=7KTrdItVhsmDUyDggdvNWAkcifUfR9oLU9QTC4MXwVE=;
        b=ufc6LA0S0wJ9lHZYFvsKzDthyVbkmb4GMuRFIAOkzroHHWs/85DC40sEnUVv/P0TWk
         EEhLXFDcnTpJOPzrTcshvlxPvPROUI+l7f9YGREXhwjEbkOxRZyYV2xxceY6/BvE5CKd
         u6uOq4xZ1SKbHIGNsCtBD3PZxoV8wU1gQ/drQdSETgVjC9zpCzlGMMZyj5BlA8YbIyLN
         VnC9yDnrEH95AgATau6JIveU4kvNCUKL2fdjCXymHnsLoMirf+xNZHPK/TgPAShqn0XC
         8UuyXqjrKvcMZpdqg0Gpnm4hRrRD107YOLzA+iW68w5+cLFseGgXJDhhXmdBwqynRf3O
         DnhQ==
X-Gm-Message-State: APjAAAWiMYAWxtiXHmf7UuUWNTyB5bN3aGMESQnyvoZ3Gw7yRr5GdrW4
	1PZGCbxZlAJIwxNQodA11axygg==
X-Google-Smtp-Source: APXvYqw0WWTZFkrdOvkT8Sl055md9Tbaxub+/8kS6b9Z6Yj3wpO+k566Ql1RaoX0X7zqvkboABLXVw==
X-Received: by 2002:a62:37c5:: with SMTP id e188mr35417324pfa.207.1567434773580;
        Mon, 02 Sep 2019 07:32:53 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id s186sm19233794pfb.126.2019.09.02.07.32.52
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 02 Sep 2019 07:32:52 -0700 (PDT)
From: Daniel Axtens <dja@axtens.net>
To: Mark Rutland <mark.rutland@arm.com>
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, x86@kernel.org, aryabinin@virtuozzo.com, glider@google.com, luto@kernel.org, linux-kernel@vger.kernel.org, dvyukov@google.com, christophe.leroy@c-s.fr, linuxppc-dev@lists.ozlabs.org, gor@linux.ibm.com
Subject: Re: [PATCH v6 1/5] kasan: support backing vmalloc space with real shadow memory
In-Reply-To: <20190902132220.GA9922@lakrids.cambridge.arm.com>
References: <20190902112028.23773-1-dja@axtens.net> <20190902112028.23773-2-dja@axtens.net> <20190902132220.GA9922@lakrids.cambridge.arm.com>
Date: Tue, 03 Sep 2019 00:32:49 +1000
Message-ID: <87pnkiu5ta.fsf@dja-thinkpad.axtens.net>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Mark,

>> +static int kasan_depopulate_vmalloc_pte(pte_t *ptep, unsigned long addr,
>> +					void *unused)
>> +{
>> +	unsigned long page;
>> +
>> +	page = (unsigned long)__va(pte_pfn(*ptep) << PAGE_SHIFT);
>> +
>> +	spin_lock(&init_mm.page_table_lock);
>> +
>> +	if (likely(!pte_none(*ptep))) {
>> +		pte_clear(&init_mm, addr, ptep);
>> +		free_page(page);
>> +	}
>> +	spin_unlock(&init_mm.page_table_lock);
>> +
>> +	return 0;
>> +}
>
> There needs to be TLB maintenance after unmapping the page, but I don't
> see that happening below.
>
> We need that to ensure that errant accesses don't hit the page we're
> freeing and that new mappings at the same VA don't cause a TLB conflict
> or TLB amalgamation issue.

Darn it, I knew there was something I forgot to do! I thought of that
over the weekend, didn't write it down, and then forgot it when I went
to respin the patches. You're totally right.

>
>> +/*
>> + * Release the backing for the vmalloc region [start, end), which
>> + * lies within the free region [free_region_start, free_region_end).
>> + *
>> + * This can be run lazily, long after the region was freed. It runs
>> + * under vmap_area_lock, so it's not safe to interact with the vmalloc/vmap
>> + * infrastructure.
>> + */
>
> IIUC we aim to only free non-shared shadow by aligning the start
> upwards, and aligning the end downwards. I think it would be worth
> mentioning that explicitly in the comment since otherwise it's not
> obvious how we handle races between alloc/free.
>

Oh, I will need to think through that more carefully.

I think the vmap_area_lock protects us against alloc/free races. I think
alignment operates at least somewhat as you've described, and while it
is important for correctness, I'm not sure I'd say it prevented races? I
will double check my understanding of vmap_area_lock, and I agree the
comment needs to be much clearer.

Once again, thanks for your patience and thoughtful review.

Regards,
Daniel

> Thanks,
> Mark.
>
>> +void kasan_release_vmalloc(unsigned long start, unsigned long end,
>> +			   unsigned long free_region_start,
>> +			   unsigned long free_region_end)
>> +{
>> +	void *shadow_start, *shadow_end;
>> +	unsigned long region_start, region_end;
>> +
>> +	/* we start with shadow entirely covered by this region */
>> +	region_start = ALIGN(start, PAGE_SIZE * KASAN_SHADOW_SCALE_SIZE);
>> +	region_end = ALIGN_DOWN(end, PAGE_SIZE * KASAN_SHADOW_SCALE_SIZE);
>> +
>> +	/*
>> +	 * We don't want to extend the region we release to the entire free
>> +	 * region, as the free region might cover huge chunks of vmalloc space
>> +	 * where we never allocated anything. We just want to see if we can
>> +	 * extend the [start, end) range: if start or end fall part way through
>> +	 * a shadow page, we want to check if we can free that entire page.
>> +	 */
>> +
>> +	free_region_start = ALIGN(free_region_start,
>> +				  PAGE_SIZE * KASAN_SHADOW_SCALE_SIZE);
>> +
>> +	if (start != region_start &&
>> +	    free_region_start < region_start)
>> +		region_start -= PAGE_SIZE * KASAN_SHADOW_SCALE_SIZE;
>> +
>> +	free_region_end = ALIGN_DOWN(free_region_end,
>> +				     PAGE_SIZE * KASAN_SHADOW_SCALE_SIZE);
>> +
>> +	if (end != region_end &&
>> +	    free_region_end > region_end)
>> +		region_end += PAGE_SIZE * KASAN_SHADOW_SCALE_SIZE;
>> +
>> +	shadow_start = kasan_mem_to_shadow((void *)region_start);
>> +	shadow_end = kasan_mem_to_shadow((void *)region_end);
>> +
>> +	if (shadow_end > shadow_start)
>> +		apply_to_page_range(&init_mm, (unsigned long)shadow_start,
>> +				    (unsigned long)(shadow_end - shadow_start),
>> +				    kasan_depopulate_vmalloc_pte, NULL);
>> +}

