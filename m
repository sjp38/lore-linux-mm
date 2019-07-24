Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93245C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 21:36:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47B4E216F4
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 21:36:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47B4E216F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D60388E000D; Wed, 24 Jul 2019 17:36:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D103C8E0002; Wed, 24 Jul 2019 17:36:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD8458E000D; Wed, 24 Jul 2019 17:36:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7110B8E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 17:36:53 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y3so30910411edm.21
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 14:36:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :content-transfer-encoding:date:from:to:cc:subject:in-reply-to
         :references:message-id:user-agent;
        bh=hIcv+QIZUOKonKzD5p7Xpnug4v3G04PkzSxccjFzQLE=;
        b=Vxc52AD+K9XiMgV2hMsUi7u5E6zQHlYixw8QAWiXU2h8TsQDBcFwQqd5NVqwcKbkat
         ejlbX9gG+ASQaNh+ZylqL20IYtCZUTkgdnEZEGZ3Yg+1AE6BWGl7bEvlABL45UH8S83R
         A7sptSn4XODGi72DtwXY3tnfGEUFzVsGwfVq+9qWgbd06S8cwgCwXumhXJOj+qHPQYmV
         bqT5vqd3GOkUX+n94YGDpVsKcGiEdpuAQ12w1LP7inWknsPBQsnNGA/qsOqnmS37IVY9
         SL0uxGlKQ/K6lFmlHd3iplnD19L5MVIFAX2b+G+yLPYYaOxeBowgHVQ1q5jx+rZhAMB3
         yQnw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVrQiIMZBLLIMpgOv/NBw+n1qbXgyl4KMQuCyqnf3IhJjABTQ4z
	zdJq16m4xfNdTbzs1hNErdW8jFyWmJ79TV6T0YIJyDdWJrI7MAwj2erTgknQ6P6Sbb3m2Nsebkp
	WOyVEvlsRh2vwg4grTt575iRuyK8Z6ZZNfVivXyRQiWwOnv5t64zSZdNZvRrJdOCwUA==
X-Received: by 2002:a17:906:7f16:: with SMTP id d22mr64899142ejr.17.1564004213017;
        Wed, 24 Jul 2019 14:36:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwyUTnx6djcy7VhBUoUlWe05aU4jh9eGljV1gt183ktYUs02HRQVXNUxuZmNVghdPlj0qpN
X-Received: by 2002:a17:906:7f16:: with SMTP id d22mr64899111ejr.17.1564004212250;
        Wed, 24 Jul 2019 14:36:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564004212; cv=none;
        d=google.com; s=arc-20160816;
        b=HYZUaKOhrVpP6OYtHIzZaKsKZmSa66MgLF2KqOCYawEb+JGcKb+Mw0ZHe+cbw8qMOi
         kr5wN+5axl++ZC046nYgMXiD+rYqPotwHMw7MuV1ZVq3BOFCgYo1JpN4zGcw4DBbnOmd
         OP/Ix6Z8U3ZGHlr+C3we1ZJkZbHUUx9x6LpIX+W+FIqgIYRQ21UTU1PE0xofgXYQKp5f
         uPZyh/g2Lj7eojNBbUSeFKljHsfa82QGE+O+fpUar3m4CENaWJE4OGvuwaSR+w6x5d/E
         Qodv+/wMKMxOjshU/wS5ZIWcX3cnQZ/Mx1T+j1Th7ZFLoKyQpBkW0dwMsXs0TtuR+o8/
         hMnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:message-id:references:in-reply-to:subject:cc:to:from
         :date:content-transfer-encoding:mime-version;
        bh=hIcv+QIZUOKonKzD5p7Xpnug4v3G04PkzSxccjFzQLE=;
        b=uzvcRQH8ocDqG4yYwwwQUvOJezSczsBDB8tIiOMvoMpOYHNyoh0JSSdLeVmOukoIV8
         1d1dd0hIZHAbD0YxKEyEDG1deiT7DYqUvlLBsANhxwEE1ZA4bTiUxUdWaN+e3nU/FrsK
         shkITGSWDWGUNfnmhmmNbOos1xDPN/C95mHdPsXCdiMk66GBADCFGRFKr2w3duX6VZcE
         79W2FHSCWLJPn+FqjpER+goZMaqend+esB31UOA1XAWCtHs41dd/LmjslC7C33hf1gIE
         riQXJo8Gd2YyXNECR38dDGUxWqoN/IOllSfZsqPlRe4ObKspBNVXG6pZtRe7HK4VgIzX
         imjw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l23si8107137eja.304.2019.07.24.14.36.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 14:36:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 33E6CABC6;
	Wed, 24 Jul 2019 21:36:51 +0000 (UTC)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Wed, 24 Jul 2019 23:36:49 +0200
From: osalvador@suse.de
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko
 <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, Jonathan
 Cameron <Jonathan.Cameron@huawei.com>, David Hildenbrand <david@redhat.com>,
 Anshuman Khandual <anshuman.khandual@arm.com>, Vlastimil Babka
 <vbabka@suse.cz>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List
 <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2 2/5] mm,memory_hotplug: Introduce MHP_VMEMMAP_FLAGS
In-Reply-To: <CAPcyv4hvu+wp4tJJNW70jp2G_rNabyvzGMvDTS3PzkDCAFztYg@mail.gmail.com>
References: <20190625075227.15193-1-osalvador@suse.de>
 <20190625075227.15193-3-osalvador@suse.de>
 <CAPcyv4hvu+wp4tJJNW70jp2G_rNabyvzGMvDTS3PzkDCAFztYg@mail.gmail.com>
Message-ID: <b9eb327f64e6727c5c2db474089d510d@suse.de>
X-Sender: osalvador@suse.de
User-Agent: Roundcube Webmail
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-07-24 22:11, Dan Williams wrote:
> On Tue, Jun 25, 2019 at 12:53 AM Oscar Salvador <osalvador@suse.de> 
> wrote:
>> 
>> This patch introduces MHP_MEMMAP_DEVICE and MHP_MEMMAP_MEMBLOCK flags,
>> and prepares the callers that add memory to take a "flags" parameter.
>> This "flags" parameter will be evaluated later on in Patch#3
>> to init mhp_restrictions struct.
>> 
>> The callers are:
>> 
>> add_memory
>> __add_memory
>> add_memory_resource
>> 
>> Unfortunately, we do not have a single entry point to add memory, as 
>> depending
>> on the requisites of the caller, they want to hook up in different 
>> places,
>> (e.g: Xen reserve_additional_memory()), so we have to spread the 
>> parameter
>> in the three callers.
>> 
>> The flags are either MHP_MEMMAP_DEVICE or MHP_MEMMAP_MEMBLOCK, and 
>> only differ
>> in the way they allocate vmemmap pages within the memory blocks.
>> 
>> MHP_MEMMAP_MEMBLOCK:
>>         - With this flag, we will allocate vmemmap pages in each 
>> memory block.
>>           This means that if we hot-add a range that spans multiple 
>> memory blocks,
>>           we will use the beginning of each memory block for the 
>> vmemmap pages.
>>           This strategy is good for cases where the caller wants the 
>> flexiblity
>>           to hot-remove memory in a different granularity than when it 
>> was added.
>> 
>>           E.g:
>>                 We allocate a range (x,y], that spans 3 memory blocks, 
>> and given
>>                 memory block size = 128MB.
>>                 [memblock#0  ]
>>                 [0 - 511 pfns      ] - vmemmaps for section#0
>>                 [512 - 32767 pfns  ] - normal memory
>> 
>>                 [memblock#1 ]
>>                 [32768 - 33279 pfns] - vmemmaps for section#1
>>                 [33280 - 65535 pfns] - normal memory
>> 
>>                 [memblock#2 ]
>>                 [65536 - 66047 pfns] - vmemmap for section#2
>>                 [66048 - 98304 pfns] - normal memory
>> 
>> MHP_MEMMAP_DEVICE:
>>         - With this flag, we will store all vmemmap pages at the 
>> beginning of
>>           hot-added memory.
>> 
>>           E.g:
>>                 We allocate a range (x,y], that spans 3 memory blocks, 
>> and given
>>                 memory block size = 128MB.
>>                 [memblock #0 ]
>>                 [0 - 1533 pfns    ] - vmemmap for section#{0-2}
>>                 [1534 - 98304 pfns] - normal memory
>> 
>> When using larger memory blocks (1GB or 2GB), the principle is the 
>> same.
>> 
>> Of course, MHP_MEMMAP_DEVICE is nicer when it comes to have a large 
>> contigous
>> area, while MHP_MEMMAP_MEMBLOCK allows us to have flexibility when 
>> removing the
>> memory.
> 
> Concept and patch looks good to me, but I don't quite like the
> proliferation of the _DEVICE naming, in theory it need not necessarily
> be ZONE_DEVICE that is the only user of that flag. I also think it
> might be useful to assign a flag for the default 'allocate from RAM'
> case, just so the code is explicit. So, how about:
> 
> MHP_MEMMAP_PAGE_ALLOC
> MHP_MEMMAP_MEMBLOCK
> MHP_MEMMAP_RESERVED
> 
> ...for the 3 cases?
> 
> Other than that, feel free to add:
> 
> Reviewed-by: Dan Williams <dan.j.williams@intel.com>
  HI Dan,

I'll be sending V3 tomorrow, with some major rewrites (more simplified).

Thanks

