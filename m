Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2619C04AB4
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 08:37:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B7362086A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 08:37:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B7362086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A8E86B0266; Mon, 13 May 2019 04:37:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0594F6B0269; Mon, 13 May 2019 04:37:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E63B86B026A; Mon, 13 May 2019 04:37:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 988E26B0266
	for <linux-mm@kvack.org>; Mon, 13 May 2019 04:37:14 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h12so16834759edl.23
        for <linux-mm@kvack.org>; Mon, 13 May 2019 01:37:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=XOQhwOxC3UX6fhkN012Z2vHX3R+RuWoAFlGRNj/4OqM=;
        b=kQEv0GGvcSkMv5RgesUW3vGh58G+IufbY2FW8+Id419S54s+2yWwGbazlve1Kju7xc
         QCRkE1GQzWWlflaO+UcfZ48Bm5KdBsa9BH37jgSQjuIVREt/9ynT8R4mgUWpcMra9zyL
         FXtjuLT3rCuP1E1SJkLY7clH9AvdX6KbqdAZ3+zfBMXjJye6yXYaBS9zM2q2S/s1fxYu
         UBCMr9lpNFxfC7uu+htkIoPKRPZxUTfJNKLA2ogOYP2dTX57L2XCgea/oMFetLJpeAu9
         mMN3LFMM8on2Ef6/x4hRmh9bMOWNRRh5Eg12oJbpKgkfIfVkci0tku9M63iyVbMK6B1c
         FHHw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAX0z9tyIBV0YBxx6Au12AGl6iAjBnjOL0UC+D5uSDl61tSop8xS
	CJF5eieQyF0cm+6duPm6h38oKB6QjAdXeh2mS3bSOtPobRpR08Jp63fOPLz7Trsx9Ikq276i127
	jHOglrJ4F1emRyysef27OAv8SZdRCCp9DPV4XSlEAwk92aTFKy0tRdWaL3nFi88S66w==
X-Received: by 2002:a50:84e1:: with SMTP id 88mr27527859edq.193.1557736634200;
        Mon, 13 May 2019 01:37:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqykHrM5bhJyZuAWL1by2mG/ZFvY8xFok75wZnlR5Yro2SF4qP8mMkN875QQ7VLo7GTKycWt
X-Received: by 2002:a50:84e1:: with SMTP id 88mr27527807edq.193.1557736633439;
        Mon, 13 May 2019 01:37:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557736633; cv=none;
        d=google.com; s=arc-20160816;
        b=aZMxy/D0nJrZDGO4z8GxyhItl5dugwvbET6lDnpvmUGT0Q+KT0K0Is12PsMloFpZK9
         Irt2csbKBzkMd45pkIr+4893xvNrtematPCLjTYD5bb7gB0rATFpUU58quo1jFO0lWnp
         r7yBEJoyz+SGSN3AuUkO6NZ992yghf/PTmcS3Ffnwioyg5FLLK83VI4g4Wx/gw2K5jBD
         Y8GxXPl/xnglzyeN5CRkhsJ3kgW7jKDcTX673ENkbiL2A/Fg1caG+KEOjTDvbx605D+v
         j3vg0t2gYXNzqPQMU5LP8ARGFcXiErTLmvxbFgbRfcp6KZCQ0uA3v6gdRHk0/3XqslET
         qbwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=XOQhwOxC3UX6fhkN012Z2vHX3R+RuWoAFlGRNj/4OqM=;
        b=kGFVUWvMM72BtPmnqRRH9ZBAKduABymZyfWLzyKsolFaIlNvtHbSIeqYLmNCzVjLt7
         bZstEEhWtXF62TNIgBk4Tx0Tzp7+1bqqn/l4AkaiBHwkvkeYMDQtJ6EqH42NiDq4egGv
         HfoWPIu+lbmUbe4VU7G2F6ycakLpN60JRYhNlxBVVFQ7Ri70YuC5d494irEuult4BzkP
         FhuATzLISOaMLeigmCmEk4B24MKedUUgZF4T6mbL7TiMVfSBrpEbppzZeKM/D1K6xQQO
         5vHAe7ecRzrRnkLIHQESFxZpZMUIwkHTZ0VsJqLg8MhWnObl9PLtxZAjV6WcPPVxhDKt
         ZcUA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x8si3047240edb.237.2019.05.13.01.37.13
        for <linux-mm@kvack.org>;
        Mon, 13 May 2019 01:37:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 5B9EB15AD;
	Mon, 13 May 2019 01:37:12 -0700 (PDT)
Received: from [10.163.1.137] (unknown [10.163.1.137])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D63E43F720;
	Mon, 13 May 2019 01:37:03 -0700 (PDT)
Subject: Re: [PATCH V2 0/2] arm64/mm: Enable memory hot remove
To: David Hildenbrand <david@redhat.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 akpm@linux-foundation.org, will.deacon@arm.com, catalin.marinas@arm.com
Cc: mhocko@suse.com, mgorman@techsingularity.net, james.morse@arm.com,
 mark.rutland@arm.com, robin.murphy@arm.com, cpandya@codeaurora.org,
 arunks@codeaurora.org, dan.j.williams@intel.com, osalvador@suse.de,
 cai@lca.pw, logang@deltatee.com, ira.weiny@intel.com
References: <1555221553-18845-1-git-send-email-anshuman.khandual@arm.com>
 <bbfc6ede-01b2-2331-112e-fa28bc2591fb@redhat.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <67efff12-6d7f-9696-0c34-c9ad11acd297@arm.com>
Date: Mon, 13 May 2019 14:07:11 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <bbfc6ede-01b2-2331-112e-fa28bc2591fb@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 05/13/2019 01:52 PM, David Hildenbrand wrote:
> On 14.04.19 07:59, Anshuman Khandual wrote:
>> This series enables memory hot remove on arm64 after fixing a memblock
>> removal ordering problem in generic __remove_memory(). This is based
>> on the following arm64 working tree.
>>
>> git://git.kernel.org/pub/scm/linux/kernel/git/arm64/linux.git for-next/core
>>
>> Testing:
>>
>> Tested hot remove on arm64 for all 4K, 16K, 64K page config options with
>> all possible VA_BITS and PGTABLE_LEVELS combinations. Build tested on non
>> arm64 platforms.
>>
>> Changes in V2:
>>
>> - Added all received review and ack tags
>> - Split the series from ZONE_DEVICE enablement for better review
>>
>> - Moved memblock re-order patch to the front as per Robin Murphy
>> - Updated commit message on memblock re-order patch per Michal Hocko
>>
>> - Dropped [pmd|pud]_large() definitions
>> - Used existing [pmd|pud]_sect() instead of earlier [pmd|pud]_large()
>> - Removed __meminit and __ref tags as per Oscar Salvador
>> - Dropped unnecessary 'ret' init in arch_add_memory() per Robin Murphy
>> - Skipped calling into pgtable_page_dtor() for linear mapping page table
>>   pages and updated all relevant functions
>>
>> Changes in V1: (https://lkml.org/lkml/2019/4/3/28)
>>
>> Anshuman Khandual (2):
>>   mm/hotplug: Reorder arch_remove_memory() call in __remove_memory()
>>   arm64/mm: Enable memory hot remove
>>
>>  arch/arm64/Kconfig               |   3 +
>>  arch/arm64/include/asm/pgtable.h |   2 +
>>  arch/arm64/mm/mmu.c              | 221 ++++++++++++++++++++++++++++++++++++++-
>>  mm/memory_hotplug.c              |   3 +-
>>  4 files changed, 225 insertions(+), 4 deletions(-)
>>
> 
> What's the progress of this series? I'll need arch_remove_memory() for
> the series
> 
> [PATCH v2 0/8] mm/memory_hotplug: Factor out memory block device handling
> 

Hello David,

I am almost done with the next version with respect to memory hot-remove i.e
arch_remove_memory(). But most of the time was spent addressing concerns with
respect to how memory hot remove is going to impact existing arm64 and generic
code which can concurrently walk or modify init_mm page table. I should be
sending out V3 this week or early next week.

- Anshuman   

