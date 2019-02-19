Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C64EC10F00
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 16:55:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 506FE2183E
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 16:55:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 506FE2183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFAF28E0003; Tue, 19 Feb 2019 11:55:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAB2C8E0002; Tue, 19 Feb 2019 11:55:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC0D28E0003; Tue, 19 Feb 2019 11:55:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 777AE8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 11:55:37 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id j5so5131433edt.17
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 08:55:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=iGrys795jB7cOZzDU6moZgJYPWm6LlPQ2WfLLkm3TN8=;
        b=pBcV05dVvm/siSNqNM5rpedijIhbWKK/yiAM3GmIYjGYthkMD5Rhd5CFEV1sXRdIh8
         63ZCK2xja9dqyFjDjWcT4QngJ8/Bp8N02+MY57JEjAbIhUpKfxKDUitc4waP5Z6V3Z8s
         0mLHvf1tbOz+A3I0hqO28MkZfUuuCmGbL86CqWrQeRDTQQReSRJ0sEOCAqkDavyiBiI+
         y18t4o2S6Jsm3AxgqNajc4BO320APzybyDtbGsLgyJpNwAc3Nc9yOZpPncmr48FVEYCR
         YSi/g7hVjGmDvUNzcLRyyQWVkd2g1njBXMSszozEUnLF/TtQlDtIKLJw6H116OWIhLDb
         Wccg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAubyKNJNhAi0Ua3bK8proSQX9puf53jfuHxiH2KeeOiJ1ykDuE9p
	zgLmKkAapF3BbEFgsNTjfcW62Nqo+K4tVAEgDNCPM1wuIY6jIHltLfEXaWANK4j4D3GxAIMXdNa
	5s6m6jo9GWSLYxtg1ONAyysxwyPmFSYQA+D/F2u3bzhu/0D590P/9xOqv7IbFqyw5tQ==
X-Received: by 2002:aa7:c3d3:: with SMTP id l19mr12752246edr.117.1550595337027;
        Tue, 19 Feb 2019 08:55:37 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZOsHnHcnIb14+QGbho/lPG5he5XSAJxLA0Etqvd7Ys+vYYmh57mHmUBlrKNzu8zS/wZFJx
X-Received: by 2002:aa7:c3d3:: with SMTP id l19mr12752195edr.117.1550595336201;
        Tue, 19 Feb 2019 08:55:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550595336; cv=none;
        d=google.com; s=arc-20160816;
        b=St0NTSyOKxnfjPiV09LPCSXod+oj/+oWswSFZkrQrVAVu5jLNG53Eem0FH0N4fNWRO
         sELdvfwuW3b4HugtI+HXezrcjsTpcBAqsjJcMxdCA/eTJyNwQPXNEr9keEG71QjzwvDM
         radiuBrqBw5QvFnyd6se/XJNu8nOSnVWk/vf2XMH0fqluMMi3yWoZBrrQJ9KVHmFeGip
         wsC1llVikWsOSjpDlLjhdLkWusoZJFkyq0ESKrkHHiXZMYFgJD/oRwIUVgauWEekJcDq
         uXK8Vuszp8iYhzCUiMrEisDOy9z9HXCRWQmdOX2Zn4QZASWHKOltUk3Adg/KM3t3tnpc
         fIjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:openpgp:from:references:cc:to:subject;
        bh=iGrys795jB7cOZzDU6moZgJYPWm6LlPQ2WfLLkm3TN8=;
        b=m8KepfARvMXzsHiGEyk/ouRf4BR1aKEdRlFTaUa6KfalTWTORn7lVtFf82SUr+mTTE
         rbdYOd6csUkGbhetjeBbMOq6vG7gJXViEau0UczpyP4qJar5q/RxXTi5f2Ky+Rs13XDb
         Ra3JGd3V0t98kcWzIh0zaENkuCRGA51kEwziSo0V8o9lmObmAXXvD8k9MSK7SNg3ofee
         /x2Oh0ZO1uazwzOUCqZff4ecKbChiAI2Kt+WYZNmO/tcI1kEnTUy+E/sgJVJDyDqRGYI
         u3h0LPymXs4Dou4eVyZuZK3gWry9v3uPD/BQ3pbvhrLB/YK7Mmvv10HAZz/daq8oCtos
         SHOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s23si3729431ejq.139.2019.02.19.08.55.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 08:55:36 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 29031AAA9;
	Tue, 19 Feb 2019 16:55:35 +0000 (UTC)
Subject: Re: [PATCH] mm/cma: cma_declare_contiguous: correct err handling
To: Andrew Morton <akpm@linux-foundation.org>, Peng Fan <peng.fan@nxp.com>
Cc: "labbott@redhat.com" <labbott@redhat.com>,
 "mhocko@suse.com" <mhocko@suse.com>,
 "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>,
 "rppt@linux.vnet.ibm.com" <rppt@linux.vnet.ibm.com>,
 "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>,
 "rdunlap@infradead.org" <rdunlap@infradead.org>,
 "andreyknvl@google.com" <andreyknvl@google.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "van.freenix@gmail.com" <van.freenix@gmail.com>,
 Mike Rapoport <rppt@linux.ibm.com>, Catalin Marinas <catalin.marinas@arm.com>
References: <20190214125704.6678-1-peng.fan@nxp.com>
 <20190214123824.fe95cc2e603f75382490bfb4@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Message-ID: <b78470e8-b204-4a7e-f9cc-eff9c609f480@suse.cz>
Date: Tue, 19 Feb 2019 17:55:33 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190214123824.fe95cc2e603f75382490bfb4@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/14/19 9:38 PM, Andrew Morton wrote:
> On Thu, 14 Feb 2019 12:45:51 +0000 Peng Fan <peng.fan@nxp.com> wrote:
> 
>> In case cma_init_reserved_mem failed, need to free the memblock allocated
>> by memblock_reserve or memblock_alloc_range.
>>
>> ...
>>
>> --- a/mm/cma.c
>> +++ b/mm/cma.c
>> @@ -353,12 +353,14 @@ int __init cma_declare_contiguous(phys_addr_t base,
>>  
>>  	ret = cma_init_reserved_mem(base, size, order_per_bit, name, res_cma);
>>  	if (ret)
>> -		goto err;
>> +		goto free_mem;
>>  
>>  	pr_info("Reserved %ld MiB at %pa\n", (unsigned long)size / SZ_1M,
>>  		&base);
>>  	return 0;
>>  
>> +free_mem:
>> +	memblock_free(base, size);
>>  err:
>>  	pr_err("Failed to reserve %ld MiB\n", (unsigned long)size / SZ_1M);
>>  	return ret;
> 
> This doesn't look right to me.  In the `fixed==true' case we didn't
> actually allocate anything and in the `fixed==false' case, the
> allocated memory is at `addr', not at `base'.

I think it's ok as the fixed==true path has "memblock_reserve()", but
better leave this to the memblock maintainer :)

There's also 'kmemleak_ignore_phys(addr)' which should probably be
undone (or not called at all) in the failure case. But it seems to be
missing from the fixed==true path?

