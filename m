Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08C96C282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 09:52:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A943D20693
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 09:52:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A943D20693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 120276B0003; Tue, 16 Apr 2019 05:52:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D04B6B0006; Tue, 16 Apr 2019 05:52:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F00806B0007; Tue, 16 Apr 2019 05:52:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A2B116B0003
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 05:52:38 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id o8so9897689edh.12
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 02:52:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=g8kViWFSq5Y/vSV8L39pAVnVoiuAhp+dDTmn/QmEpgw=;
        b=B4UWtNxF4YzvVkOwv9bpEu0Qo8csE6HBTGe3N1A8mDpbJNLZ5R6OWikSbd/JQgbo90
         WXBCYln/awgE9ykhDUN0DdubZiaUpnMKAAtpXYbWK3di+DlZJj8B1baUteqrEnYfM4yR
         BD0J1I7u63Zo0I6k9VRe93/TQyEOm1fKrUHWk1kX7rAfYzMp+NSFQKKnWP10NExAXlMm
         J4F1Kbf81Q9oUwiJ2N22I2wi3E+tjxezI+CFBCGhG1QG52HB+F9G0hGqSUznNjwZ3RsX
         K/unSoSXIwUNhLuLDdzLti8uJoj+jMAcQ5UwwyESgTgb7yGHQZye3wKz+wDDF/344v/P
         UOpw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVbnjSuByNd1t+T0GT3cw/QrCkrOxbVDzo6wgIkF0WAgE2KNTWE
	zFmos2bGubiMsHL1ULQLfH92s+SsIrSIE3642qcTRcIc9CJSuvhTFHyeC+6eaCydISRPAmeJ0t6
	BBe8XHxyPZHJMskIadFUeo7oYVvVHhMw9byc6gcnqjvH4wMPJU8VEINJX61wWn27ACQ==
X-Received: by 2002:a50:978e:: with SMTP id e14mr15501252edb.91.1555408358109;
        Tue, 16 Apr 2019 02:52:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0L4IAOyLbi1U6e4z+99kFvHcLQRod/yPrTsHP6u703KX1atcpadro7zSkVwOeFvlIUV95
X-Received: by 2002:a50:978e:: with SMTP id e14mr15501197edb.91.1555408356994;
        Tue, 16 Apr 2019 02:52:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555408356; cv=none;
        d=google.com; s=arc-20160816;
        b=GrnSwpVMbCNIDtYI2ta/M8GCiCGNbMj/XUxaoaR0SZvdiZUI/VeenDrN648BnMPyQW
         fLXxWSri1qvX69qDxgMXoreaW5iEsae/iv667gf+yuuhORyf5c6ymrirgMojqPrTAMka
         hHPSvShhIiorLbgKDWcmJWKKSj8vGSwysE5zVqebv82gDyrifE1SA04LsrIU8+NFXOwa
         h2LEjfthwpysn8+4t1nJtjyl76cBq83t1Q14szkCESPi2P/rxrtLNYLhAm37Dr4fus9O
         a1bx/cMu/bmSdla/05lbjzuonqqJr7vOmCPGOckBu+zm97AoBldqa8VaiOALI7D80XHT
         VkjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=g8kViWFSq5Y/vSV8L39pAVnVoiuAhp+dDTmn/QmEpgw=;
        b=rszxM+1+dQ0eiy+uHc+Eu6TBedAkVM86rlItoQylJ6ufu5opR0+R3CbKy7NEBD8dSS
         LOqmNwuMpiK9c2C4ji6ZWzAKockRlqzX2rC/DdT2th9rWFmruytZLtUAiLqRNc5GScIf
         VQxc8BJZsSdg2LoK6u8KycCbfjg0RqT5W4xE60ARigU8OmmVJFhz4GnI634skqv5snza
         GAy3nrQYnf6nsFOtDJMT7wGh6m++maa4BEFYjueaNi1V23bpxyD0Wo1MBRr9eMwAd56d
         k9R7Vh5g06kyTa1NQru4atOJ4uyXc3h574q1+FptwoDRwdsUFPIJHET2wemHjRgMDCrC
         pshg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z3si9958031edp.192.2019.04.16.02.52.36
        for <linux-mm@kvack.org>;
        Tue, 16 Apr 2019 02:52:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id DEEE380D;
	Tue, 16 Apr 2019 02:52:35 -0700 (PDT)
Received: from [10.162.42.238] (p8cg001049571a15.blr.arm.com [10.162.42.238])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id BA29A3F68F;
	Tue, 16 Apr 2019 02:52:29 -0700 (PDT)
Subject: Re: [PATCH V2 2/2] arm64/mm: Enable memory hot remove
To: David Hildenbrand <david@redhat.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 akpm@linux-foundation.org, will.deacon@arm.com, catalin.marinas@arm.com
Cc: mhocko@suse.com, mgorman@techsingularity.net, james.morse@arm.com,
 mark.rutland@arm.com, robin.murphy@arm.com, cpandya@codeaurora.org,
 arunks@codeaurora.org, dan.j.williams@intel.com, osalvador@suse.de,
 cai@lca.pw, logang@deltatee.com, ira.weiny@intel.com
References: <1555221553-18845-1-git-send-email-anshuman.khandual@arm.com>
 <1555221553-18845-3-git-send-email-anshuman.khandual@arm.com>
 <614fe7d2-cc5d-61a2-6894-026e30498269@redhat.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <eeff6d30-f6c9-733b-5a27-76d2a80c649d@arm.com>
Date: Tue, 16 Apr 2019 15:22:28 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <614fe7d2-cc5d-61a2-6894-026e30498269@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 04/15/2019 07:25 PM, David Hildenbrand wrote:
>> +
>> +#ifdef CONFIG_MEMORY_HOTREMOVE
>> +int arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
>> +{
>> +	unsigned long start_pfn = start >> PAGE_SHIFT;
>> +	unsigned long nr_pages = size >> PAGE_SHIFT;
>> +	struct zone *zone = page_zone(pfn_to_page(start_pfn));
>> +	int ret;
>> +
>> +	ret = __remove_pages(zone, start_pfn, nr_pages, altmap);
>> +	if (!ret)
> Please note that I posted patches that remove all error handling
> from arch_remove_memory and __remove_pages(). They are already in next/master
> 
> So this gets a lot simpler and more predictable.
> 
> 
> Author: David Hildenbrand <david@redhat.com>
> Date:   Wed Apr 10 11:02:27 2019 +1000
> 
>     mm/memory_hotplug: make __remove_pages() and arch_remove_memory() never fail
>     
>     All callers of arch_remove_memory() ignore errors.  And we should really
>     try to remove any errors from the memory removal path.  No more errors are
>     reported from __remove_pages().  BUG() in s390x code in case
>     arch_remove_memory() is triggered.  We may implement that properly later.
>     WARN in case powerpc code failed to remove the section mapping, which is
>     better than ignoring the error completely right now

Sure will follow suit next time around.

