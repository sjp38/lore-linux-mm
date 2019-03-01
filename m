Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 566D5C10F03
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 10:51:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1CE502087E
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 10:51:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1CE502087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B022B8E0003; Fri,  1 Mar 2019 05:51:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8B3A8E0001; Fri,  1 Mar 2019 05:51:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A3168E0003; Fri,  1 Mar 2019 05:51:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 288358E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 05:51:02 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id d15so4031610ljg.3
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 02:51:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=EBQ+nZsyDWJTzcOlo9GrDXg6rCUBjuuZJGksrqrehuE=;
        b=YrXIWUtAa5t2fwaW2fszxICoBtIYbAtp5k+ZTTxZHauvqzdG12/ZalGQs6IJoTrY24
         Hvz12zZSPG1itMmlp4reOa5AaP7npJvfs4HIz9AGkUL3RhfEkcXNua9eN/PJzfEUQyHN
         1e5pVXJ8oVPcEGPzzr8Jkxn0PbEa2p0UOP4LI3CBceEF3gw7WuERMiEYkwUzDfPq6KYA
         xKzsJ4tz+Vw/fCvWvuylGqSwGoDEnWdKqAqnFHpkB57xT3PZBHZcDcUh4SgX/N63ZHOn
         GpKa+COYGJFcn+g0WYnVgCc6/NVHGGtMCjN5vckcr4J6x8cYDPgLX9o16YxBCb+eILBU
         IRXg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAVrWe8Z6uYQ+Okw32tWqV2GWLpwSDQhntJkuVXjU2kRrD+Lo1j5
	KI/7K8qXo3RelnaB7Du4+O/DBcZFibDNtWw3wbLSVbKaV25sHL8S8AtgrYq3zDmTnTs6KOpbg2m
	jQ2/tNGBqhG6uIfVvUbYTbKmAmn0b2Z4PIiqeLiKTCJ6+z9R2dPM/Jpolksmw81Z9wg==
X-Received: by 2002:ac2:51bc:: with SMTP id f28mr2805366lfk.123.1551437461528;
        Fri, 01 Mar 2019 02:51:01 -0800 (PST)
X-Google-Smtp-Source: APXvYqy/K7hpILvbvwhyF9A2HIEuxzAYnGQsINyuX1cM+7j81HFN2zrxvCvJL6X3RiXfXaUoOfsp
X-Received: by 2002:ac2:51bc:: with SMTP id f28mr2805297lfk.123.1551437460296;
        Fri, 01 Mar 2019 02:51:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551437460; cv=none;
        d=google.com; s=arc-20160816;
        b=cLfjHVyQdyWWiG2jpFM1Ppdm8PgzYVA2GOIL+AiFZB+ZTabylHP7xVjulTmVy0JvRB
         1cYOKrHZB13QIibEZ60vVWv0i4fHmogVeLrDeVs3w8I5GgkFUsbjTt/HORyBCvmhgyy2
         +5a4NWAHwOvn7JWgfgp7oZhpW33Ceg1sz9VUuJ7WJ0vsPjvUhYIFrWR86XK5scTGXwUZ
         F+IKbQy2iiXWnkoCwgLh4Xe4ne9yOUFA0wFDqJRRmMXKhDVVRjs/3TIrJx1fy6SBtH0q
         wXG0ggsZxU53Dk7HukbmnJVrlSZqaoCRTi4EfvCJTETquQDFu2zWoKuWOZBIZ6xwy7iC
         JQkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=EBQ+nZsyDWJTzcOlo9GrDXg6rCUBjuuZJGksrqrehuE=;
        b=jCHFTICKLyAE7NuXJtRZe8Hq96mik2coxmroVtda0TsNpB+IZqtpGY9k11wXLA3/da
         +8FUE7rj2VwBMOLN2IsAsgKA4H8iwc6bpLzZOVQUDdTOAEl9TZyHxVi0WCSX560txw1r
         TGCn9v/AlVMLhBFywHeP5mhLBaE9PW7CqgCQA/0aEF+LjZ/20kZiRrzdmjl6dmEaZios
         UjxuRKyPEVI6M4ocLhWHTWppaOeMeUePyYJAGiYRdlI1cNRYbEpz5HxRJKfmnv5yoLgz
         nuTyZgRPVp7VtQMigidfSHpsSPatMqOhNR5KVdXaH7ILINa9uSZ5QQ5MllUehVkurRP5
         A9Fw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id 29si16323136ljs.43.2019.03.01.02.51.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 02:51:00 -0800 (PST)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1gzfkk-00048B-Hz; Fri, 01 Mar 2019 13:50:54 +0300
Subject: Re: [PATCH v2 2/4] mm: remove zone_lru_lock() function access
 ->lru_lock directly
To: John Hubbard <jhubbard@nvidia.com>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>,
 Rik van Riel <riel@surriel.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>,
 Mel Gorman <mgorman@techsingularity.net>
References: <20190228083329.31892-1-aryabinin@virtuozzo.com>
 <20190228083329.31892-2-aryabinin@virtuozzo.com>
 <44ffadb4-4235-76c9-332f-680dda5da521@nvidia.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <186bf66b-fec5-a614-3ffd-64b8d7660fe5@virtuozzo.com>
Date: Fri, 1 Mar 2019 13:51:11 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.2
MIME-Version: 1.0
In-Reply-To: <44ffadb4-4235-76c9-332f-680dda5da521@nvidia.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/1/19 12:44 AM, John Hubbard wrote:
> On 2/28/19 12:33 AM, Andrey Ryabinin wrote:
>> We have common pattern to access lru_lock from a page pointer:
>> 	zone_lru_lock(page_zone(page))
>>
>> Which is silly, because it unfolds to this:
>> 	&NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)]->zone_pgdat->lru_lock
>> while we can simply do
>> 	&NODE_DATA(page_to_nid(page))->lru_lock
>>
> 
> Hi Andrey,
> 
> Nice. I like it so much that I immediately want to tweak it. :)
> 
> 
>> Remove zone_lru_lock() function, since it's only complicate things.
>> Use 'page_pgdat(page)->lru_lock' pattern instead.
> 
> Here, I think the zone_lru_lock() is actually a nice way to add
> a touch of clarity at the call sites. How about, see below:
> 
> [snip]
> 
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index 2fd4247262e9..22423763c0bd 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -788,10 +788,6 @@ typedef struct pglist_data {
>>  
>>  #define node_start_pfn(nid)	(NODE_DATA(nid)->node_start_pfn)
>>  #define node_end_pfn(nid) pgdat_end_pfn(NODE_DATA(nid))
>> -static inline spinlock_t *zone_lru_lock(struct zone *zone)
>> -{
>> -	return &zone->zone_pgdat->lru_lock;
>> -}
>>  
> 
> Instead of removing that function, let's change it, and add another
> (since you have two cases: either a page* or a pgdat* is available),
> and move it to where it can compile, like this:
> 
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 80bb6408fe73..cea3437f5d68 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1167,6 +1167,16 @@ static inline pg_data_t *page_pgdat(const struct page *page)
>         return NODE_DATA(page_to_nid(page));
>  }
>  
> +static inline spinlock_t *zone_lru_lock(pg_data_t *pgdat)
> +{
> +       return &pgdat->lru_lock;
> +}
> +


I don't think wrapper for a simple plain access to the struct member is reasonable.
Besides, there are plenty of "spin_lock(&pgdat->lru_lock)" even without this patch,
so for consistency reasons &pgdat->lru_lock seems like a better choice to me.

Also "&pgdat->lru_lock" is just shorter than:
      "node_lru_lock(pgdat)"



> +static inline spinlock_t *zone_lru_lock_from_page(struct page *page)
> +{
> +       return zone_lru_lock(page_pgdat(page));
> +}
> +

I don't think such function would find any use. Usually lru_lock is taken
to perform some manipulations with page *and* pgdat, thus it's better to remember
page_pgdat(page) in local variable.

