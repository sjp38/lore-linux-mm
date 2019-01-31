Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1420DC282DA
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 14:12:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D58F220881
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 14:12:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D58F220881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F4FF8E0002; Thu, 31 Jan 2019 09:12:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A2D68E0001; Thu, 31 Jan 2019 09:12:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B8988E0002; Thu, 31 Jan 2019 09:12:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0A8738E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 09:12:28 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id o23so2456826pll.0
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 06:12:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:openpgp:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=WOG8yS61eZRlaMGuXWzm0wKx6OHtutKRQnUtajgEYVA=;
        b=FiZHKfExjF1CLopICqHaLXmqI79JJh9il7NaBA0/QJUDRdSRLd4ixDjVJyoJBh2UWt
         0fUBgVeSjJiPFqf+ZotaLkxM/swZeuYXrCZR5PQNQViSp/LrW2x/J2ChjGGVx1zNw2hk
         lL0H7jTH5cMamu4MH/yh5TuJzgoX0W2xxmAkH3q6q7+uVvD/uor9Rz5lnJVb1Zt+hzfk
         rbyO8OmFB7fYKyQ91wGVOL4kG/n382SwV6mr4RASjRLYh0gXZCv+ph8XV33jDObPTlSx
         H93IBzrA60o1GIu7vHMUOVlPtAueLFjyBqLg9avSGrXn6n7XkfT4eA4cl4KpDu9BKykV
         h8OA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AJcUukfHXm4dP2KK00EAYaK6078PsACWzsOrFUxM9siO4wuUT13KkrRw
	ZIzbCH9Tm1NK7Cf+PWTq3+v+G/3FvhiF2TFE3g/EZGpgYwPCe0N8p8i6UpmlRrOziDuWVPvzlBN
	eE5YumKZp2Vu22igvYpy59U4BAWHW5G7Yb4xssQ/vgAcsXoNat392VZIVsTSx2R9o+Q==
X-Received: by 2002:a17:902:6502:: with SMTP id b2mr34443588plk.44.1548943947732;
        Thu, 31 Jan 2019 06:12:27 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6U2Ogxob3oRTrAk0EUsSeiqFol3KSwnbPXYPOzRdmRqBDGAR9PdqgWL4lyTmvBLapZRrnB
X-Received: by 2002:a17:902:6502:: with SMTP id b2mr34443556plk.44.1548943947055;
        Thu, 31 Jan 2019 06:12:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548943947; cv=none;
        d=google.com; s=arc-20160816;
        b=0+PJJRvJkZevY4ZA8XyY91aQoIad5Sk12XlNkouj/vkqhG2I8hgDV9848M3+3MUotW
         3Yk0xNWJ3DUuu1wdw1CCvtk31p8oknt7X2gnMvEmev8qsKK3H2DvdpD9F/WycD84GGz1
         uC+ukgG51U2Tyaplz2K5hLco4YkuRb1ll/zgKhWMWrUJSRuXloLfBQXCyhYeXiTgaQuG
         LYuRP5jbctXmPZh6rQxD9czsbM9DAv9ParwX4GlJoIZATUDxCi6snR1GE0SMgZbMrUpF
         o9mUfpCrqGZnvemSn09oaMbYOqjl5SZu4cUhQ1YDFNc34pxL8IpiCRXuC9Nw0QWweVhH
         5ezw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:openpgp:references:cc:to:from:subject;
        bh=WOG8yS61eZRlaMGuXWzm0wKx6OHtutKRQnUtajgEYVA=;
        b=bTg9EK46rM6qdx2QgKt8qooAW2VZU2KAWKDKg6qSZM2MDIODIWMpFfbw/8061W2dKW
         z3ppA2zi7iGxxs+oI0xkSPhHr4Q/H43Ouv0wbaUHBcBwGLhn5GE3qgwGJAz2mUnGgzPi
         kboI+taNX2pXRjAn10dcVV0U6V9XJn4KbSH08pkkIHfxnG20VVX6JXa2Jo53OHxx/tNh
         1zDUDKGpxKH+4MVaGwXBy+//h37Tbh/JAe6hNOU9EmXkMxOvthGUkOuNgXj2U0/zbYoI
         O1B8OU8GqrA8VdWESyACPT0aQfPPs/TqHJkIHH2ZXr/U0WjUvPWg+ogLy2r/vrCfL90W
         3muw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t3si4593682ply.126.2019.01.31.06.12.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 06:12:27 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 86EE6B02F;
	Thu, 31 Jan 2019 14:12:25 +0000 (UTC)
Subject: Re: [PATCH 09/22] mm, compaction: Use free lists to quickly locate a
 migration source
From: Vlastimil Babka <vbabka@suse.cz>
To: Mel Gorman <mgorman@techsingularity.net>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>,
 Andrea Arcangeli <aarcange@redhat.com>,
 Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
 Linux-MM <linux-mm@kvack.org>
References: <20190118175136.31341-1-mgorman@techsingularity.net>
 <20190118175136.31341-10-mgorman@techsingularity.net>
 <4a6ae9fc-a52b-4300-0edb-a0f4169c314a@suse.cz>
Openpgp: preference=signencrypt
Message-ID: <3fbf3abc-0196-9e96-3760-266395362f00@suse.cz>
Date: Thu, 31 Jan 2019 15:12:25 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <4a6ae9fc-a52b-4300-0edb-a0f4169c314a@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/31/19 2:55 PM, Vlastimil Babka wrote:
> On 1/18/19 6:51 PM, Mel Gorman wrote:
> ...
> 
>> +	for (order = cc->order - 1;
>> +	     order >= PAGE_ALLOC_COSTLY_ORDER && pfn == cc->migrate_pfn && nr_scanned < limit;
>> +	     order--) {
>> +		struct free_area *area = &cc->zone->free_area[order];
>> +		struct list_head *freelist;
>> +		unsigned long flags;
>> +		struct page *freepage;
>> +
>> +		if (!area->nr_free)
>> +			continue;
>> +
>> +		spin_lock_irqsave(&cc->zone->lock, flags);
>> +		freelist = &area->free_list[MIGRATE_MOVABLE];
>> +		list_for_each_entry(freepage, freelist, lru) {
>> +			unsigned long free_pfn;
>> +
>> +			nr_scanned++;
>> +			free_pfn = page_to_pfn(freepage);
>> +			if (free_pfn < high_pfn) {
>> +				update_fast_start_pfn(cc, free_pfn);
> 
> Shouldn't this update go below checking pageblock skip bit? We might be
> caching pageblocks that will be skipped, and also potentially going

Ah that move happens in the next patch.

