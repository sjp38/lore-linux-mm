Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30474C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 17:31:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE2AD2177E
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 17:31:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="MyZTaVId"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE2AD2177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 790FF8E0004; Mon, 18 Feb 2019 12:31:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7195E8E0002; Mon, 18 Feb 2019 12:31:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B8238E0004; Mon, 18 Feb 2019 12:31:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 261AC8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 12:31:28 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id x132so11505767ybx.22
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 09:31:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:dkim-signature;
        bh=HJkJlnLD0m3SLvolz+Or478/D93/bUDY90ZxzZo8WK4=;
        b=Q4moI8eN6qGoTVmyuAClVictmFvY8eZsfgENVXu/VzNRKziOPYaciMKqB9hiVmg2HE
         S6u7h8mccBH95mXDj4LdpnSd7XiB5Kd2I1OJZ6A3UG+StDz8Cq207CInbCssR73vQOV2
         qL5OO/BXQgs6IDd1TthXQzx+8P3UAaNJpZxq5jR143lXwB0rSC65lPTC9FQfqSrnuDnI
         /J7utLIwqGP648y2x62xCQGxFfjd0+qTe4mP82dRMDdH0uiTjQOHO06+8iQIfQx3JOfu
         Lc69RbdsqgniPXY0/ncFPJ4tXzIxwj7gtyTDkfIQv11Fl9jyEAfFs8I7sSawJt8JJcNI
         KVdg==
X-Gm-Message-State: AHQUAuaymzGjKr5WDDQjJ/D2bSz7ktJ3jl66yjEMgGogzwuQMs9KSOi7
	xaW30DkQOlglOcEFYZkxhHDsEZKcutYojSBakG4l+oedJhHk1KV86JbJAYUpxHP4wtZ68OYLnHo
	/D4DrlWQ39k6WV7FFqdCfw+kvNuvJMYq2rtDP02oR75XwBaRCqt++1RMvcCUKl+AY6w==
X-Received: by 2002:a25:b793:: with SMTP id n19mr14906186ybh.33.1550511087848;
        Mon, 18 Feb 2019 09:31:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYX6f37/FS9Jpf48nOMbf5oV5EYL4pCqC/NQ1kWy+rsYfaAJG8gP5fYQRY0HkHtjl97glnf
X-Received: by 2002:a25:b793:: with SMTP id n19mr14906140ybh.33.1550511087110;
        Mon, 18 Feb 2019 09:31:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550511087; cv=none;
        d=google.com; s=arc-20160816;
        b=nwxy+m7FXyDEvFmAtJhuF2dWvthpP7C1A/QelwhnfvvSYW1TxDI2j2rHgTkHgF8osb
         J/7D7Q4/pkQqtHTyjvwWLI6MCB5KTpWLYWPHvU9K/ldMTL+w+7amotczZv/sN3IrfBSA
         POBI8ikTPxD/j9DTSscVtHD8dOjJAsIEIXQWZhMM7/aFCzzOy8+s4qHRZz1wXeNsIAbh
         UiDXXps7xLLM91+Ac5pG6iFdVxH1wrmDRmWs9L/7OUeMItEM5yqLs4VYTKCpd6FQTg17
         tYde/F8J2vwkTpGgXWRDWJqkF55ipp2+aoKsjZO32UDXyBGxXoEZh5Awba+gFXrwxq9w
         YwXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from;
        bh=HJkJlnLD0m3SLvolz+Or478/D93/bUDY90ZxzZo8WK4=;
        b=O1i2oxT3i1+fIAubJRwOHh66UXB+PWrmesD+MMuVQywCbjO5GPbFivL5H/OpZtKBaC
         FUhbuxVHUpliyoXT9gSz3WroS+PhUh/SNHUoYjVjYXvbNqxauKHbppElXbClTZSrdi/1
         ZUdP4e0HwaDlAkkXk6oOv1QT/pYKL4zpauoP8HYFhk0q8tL3RDr+gE2JTChYJ0K5VxFw
         O/Y2xiRhc8XBcWQvrNbxhw3sjWRusOB6B+kz5e327fhBK7Aiykhi/+ZhZ+7EJPMfIVCg
         T89eo9xtTV4WUmA1cdto2cRjviaTTRLW0WW3Su+AKaAscNVzWIkGWQs3Yy8aUygoD7tq
         uRjw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=MyZTaVId;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id 136si7333320ybf.389.2019.02.18.09.31.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 09:31:27 -0800 (PST)
Received-SPF: pass (google.com: domain of ziy@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=MyZTaVId;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c6aebf20002>; Mon, 18 Feb 2019 09:31:30 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 18 Feb 2019 09:31:26 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 18 Feb 2019 09:31:26 -0800
Received: from [192.168.45.1] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Mon, 18 Feb
 2019 17:31:25 +0000
From: Zi Yan <ziy@nvidia.com>
To: Matthew Wilcox <willy@infradead.org>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, Dave Hansen
	<dave.hansen@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton
	<akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman
	<mgorman@techsingularity.net>, John Hubbard <jhubbard@nvidia.com>, Mark
 Hairgrove <mhairgrove@nvidia.com>, Nitin Gupta <nigupta@nvidia.com>, David
 Nellans <dnellans@nvidia.com>
Subject: Re: [RFC PATCH 01/31] mm: migrate: Add exchange_pages to exchange two
 lists of pages.
Date: Mon, 18 Feb 2019 09:31:24 -0800
X-Mailer: MailMate (1.12.4r5594)
Message-ID: <65A1FFA0-531C-4078-9704-3F44819C3C07@nvidia.com>
In-Reply-To: <20190217112943.GP12668@bombadil.infradead.org>
References: <20190215220856.29749-1-zi.yan@sent.com>
 <20190215220856.29749-2-zi.yan@sent.com>
 <20190217112943.GP12668@bombadil.infradead.org>
MIME-Version: 1.0
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; format=flowed
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550511090; bh=HJkJlnLD0m3SLvolz+Or478/D93/bUDY90ZxzZo8WK4=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:X-Mailer:Message-ID:
	 In-Reply-To:References:MIME-Version:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type;
	b=MyZTaVId2Dx9mHBPrizve/E6uSnTVYvxcFZ7Oyuq0t8Qq3yyWn4eJ08iIbehTWBQZ
	 w+2tFhLbgwCXmgMQMnatKYxCx59vhvICbiSOQDRsDhyiYzcH1a3lrj6NsZxuKuRvbu
	 W25F8abVndwfblbKKqcUendSHT9sXBBdLYtZpHsYr7CEaKwlRcvRlG9fq4ZMPJCpSs
	 d3Qn6mQxk28onpf768DBQWUIJUkEBeRL/psUBrNPd6BYi4wjVqpXC32sNX+ktu+unl
	 yVy72Li2XynNuOWTNTuV5NWHamFBNDqbpmhI2O5VVtYTwF6f80AOBvmk2g/bD2IMHa
	 4vJrx/ml57Y2Q==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 17 Feb 2019, at 3:29, Matthew Wilcox wrote:

> On Fri, Feb 15, 2019 at 02:08:26PM -0800, Zi Yan wrote:
>> +struct page_flags {
>> +	unsigned int page_error :1;
>> +	unsigned int page_referenced:1;
>> +	unsigned int page_uptodate:1;
>> +	unsigned int page_active:1;
>> +	unsigned int page_unevictable:1;
>> +	unsigned int page_checked:1;
>> +	unsigned int page_mappedtodisk:1;
>> +	unsigned int page_dirty:1;
>> +	unsigned int page_is_young:1;
>> +	unsigned int page_is_idle:1;
>> +	unsigned int page_swapcache:1;
>> +	unsigned int page_writeback:1;
>> +	unsigned int page_private:1;
>> +	unsigned int __pad:3;
>> +};
>
> I'm not sure how to feel about this.  It's a bit fragile versus 
> somebody adding
> new page flags.  I don't know whether it's needed or whether you can 
> just
> copy page->flags directly because you're holding PageLock.

I agree with you that current way of copying page flags individually 
could miss
new page flags. I will try to come up with something better. Copying 
page->flags as a whole
might not simply work, since the upper part of page->flags has the page 
node information,
which should not be changed. I think I need to add a helper function to 
just copy/exchange
all page flags, like calling migrate_page_stats() twice.

>> +static void exchange_page(char *to, char *from)
>> +{
>> +	u64 tmp;
>> +	int i;
>> +
>> +	for (i = 0; i < PAGE_SIZE; i += sizeof(tmp)) {
>> +		tmp = *((u64 *)(from + i));
>> +		*((u64 *)(from + i)) = *((u64 *)(to + i));
>> +		*((u64 *)(to + i)) = tmp;
>> +	}
>> +}
>
> I have a suspicion you'd be better off allocating a temporary page and
> using copy_page().  Some architectures have put a lot of effort into
> making copy_page() run faster.

When I am doing exchange_pages() between two NUMA nodes on a x86_64 
machine,
I actually can saturate the QPI bandwidth with this operation. I think 
cache
prefetching was doing its job.

The purpose of proposing exchange_pages() is to avoid allocating any new 
page,
so that we would not trigger any potential page reclaim or memory 
compaction.
Allocating a temporary page defeats the purpose.

>
>> +		xa_lock_irq(&to_mapping->i_pages);
>> +
>> +		to_pslot = radix_tree_lookup_slot(&to_mapping->i_pages,
>> +			page_index(to_page));
>
> This needs to be converted to the XArray.  radix_tree_lookup_slot() is
> going away soon.  You probably need:
>
> 	XA_STATE(to_xas, &to_mapping->i_pages, page_index(to_page));

Thank you for pointing this out. I will do the change.

>
> This is a lot of code and I'm still trying to get my head aroud it 
> all.
> Thanks for putting in this work; it's good to see this approach being
> explored.

Thank you for taking a look at the code.

--
Best Regards,
Yan Zi

