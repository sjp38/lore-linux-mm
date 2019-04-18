Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 200B2C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 05:28:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBA6F21479
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 05:28:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBA6F21479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6230E6B0006; Thu, 18 Apr 2019 01:28:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5DD366B0007; Thu, 18 Apr 2019 01:28:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E6ED6B0008; Thu, 18 Apr 2019 01:28:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0035A6B0006
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 01:28:39 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o3so640541edr.6
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 22:28:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=5nxTKfs+ujRgLMgaMI11oau6MxYPEVtPOF8UnDm+3do=;
        b=X2gEYdPEp5iCo2jWlzZTmXqlS00aolkXBv/L4J5WKbv38TSr/NFeLaPIDcLS64VVw1
         HaOaFh9TX4FFRLkCTQ1EhYcrzu/IjrdoSYm796IQTJGlRjmbrRPZnxdy1JapvuRr/nOo
         MJqLao5s3+/qCSQGwMPVdztFhyZRphwBblGhPjftWbMft2z/C5v3vf1VR2S430oJ1Zrz
         0GtG4u9v9C7yqzdW8RKF66T0Q5CKRZPeUjBVjk1eqfGnf0aAIUPMYc9tBH2CzSmLa44i
         k9R91eMZXW+cDttI2e5x2WUmLFSZEVV3+pna6gp8VDaNpEOFlCO3nIdZk9fscPdBcV7N
         BE/g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWwLDZaJPR/BmThWOCgUjHafM9Gm3WFPQzYWnMG9eISy5pRVtHS
	YcIzkgjO70icaDGaq8SaLvbr0pFOyx80y9wp+gZVxZxMZfKHGalMeAJS7GR4rq1Qj4WaUQxoazQ
	w9lnWLTLIch/RWPgw+AjKLCaQCCfCFP3bb8DZKvjDa8NrEvHp3rYAI+8KS9slUK1Lyg==
X-Received: by 2002:a50:a5f7:: with SMTP id b52mr740608edc.84.1555565318561;
        Wed, 17 Apr 2019 22:28:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzpn2XB0K+4iC3LhSlYi6bnhcxwR/myWXAhDYSf6/bTlPFYvdJRc2dbSJp7oMIcMSjUQqzu
X-Received: by 2002:a50:a5f7:: with SMTP id b52mr740575edc.84.1555565317698;
        Wed, 17 Apr 2019 22:28:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555565317; cv=none;
        d=google.com; s=arc-20160816;
        b=fudZ34cIoejagXXDV03IJqKXX+aiDEz0LqaeJpKTqAl/XnCPjixvjCPhDvzc0L7Qb5
         zinxHur2UsjivHieoh02ZtUu/48/flkDDP5zTN42ukGp7S77xdEHWcCtfZDakZeW1RTo
         FqTwNaaO/dkuiQLlA3bTIG/aVZms7luoK/SZIPyTdhNJTbSKtjy4lSOsgWhNhCb9iFbW
         pQd6PUCWVtDMwZ+lzBL3oflOaxD+PHMR0y1KAIP6e8ZkMUzPfQ/5NQR0CcyY101b9lzy
         8eUDZOhcr2x3Ip4a+EUjjjCVRZtAUIAn/cGZA9zKyzFFzC/nT+RaWOoiVoMlC+xIfkVQ
         kV/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from;
        bh=5nxTKfs+ujRgLMgaMI11oau6MxYPEVtPOF8UnDm+3do=;
        b=OQgKJ9tavJ5t/BwCmKnMuI3okxaC2S7Vwh3Go7mZRuepk7drZiCYLyZcZqvegJFV/u
         7ZSdwnjSE03Uv9sBwmmBZ/m5LWD6VWWoPJ8LRrRFBIkK+/XH1fY3Rhx5cXBQnco+lsYh
         2ylftN8eROXOaVDyOtXwWsPHbfkWMiYtbiaAlZxj3qEv3xHW0T5XD6bNZuLULogfBapj
         MR4SREtx+y/CyoJbRqO0In16/OEGP8WYr+5RUCL2lOs33yWbHi2H9bBv2CwGyhmP/xkJ
         dhGf7yNVHce9KZD++/2dXRVjbymxFagqQZbwKE8BTU744s1T2FeydxR0sk1H49RrOAlh
         Cubw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x14si638924ejc.84.2019.04.17.22.28.37
        for <linux-mm@kvack.org>;
        Wed, 17 Apr 2019 22:28:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 54CD980D;
	Wed, 17 Apr 2019 22:28:36 -0700 (PDT)
Received: from [192.168.0.129] (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E6E9D3F68F;
	Wed, 17 Apr 2019 22:28:30 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [PATCH V2 2/2] arm64/mm: Enable memory hot remove
To: Mark Rutland <mark.rutland@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-mm@kvack.org, akpm@linux-foundation.org, will.deacon@arm.com,
 catalin.marinas@arm.com, mhocko@suse.com, mgorman@techsingularity.net,
 james.morse@arm.com, robin.murphy@arm.com, cpandya@codeaurora.org,
 arunks@codeaurora.org, dan.j.williams@intel.com, osalvador@suse.de,
 david@redhat.com, cai@lca.pw, logang@deltatee.com, ira.weiny@intel.com
References: <1555221553-18845-1-git-send-email-anshuman.khandual@arm.com>
 <1555221553-18845-3-git-send-email-anshuman.khandual@arm.com>
 <20190415134841.GC13990@lakrids.cambridge.arm.com>
 <2faba38b-ab79-2dda-1b3c-ada5054d91fa@arm.com>
 <20190417142154.GA393@lakrids.cambridge.arm.com>
 <bba0b71c-2d04-d589-e2bf-5de37806548f@arm.com>
 <20190417173948.GB15589@lakrids.cambridge.arm.com>
Message-ID: <1bdae67b-fcd6-7868-8a92-c8a306c04ec6@arm.com>
Date: Thu, 18 Apr 2019 10:58:29 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190417173948.GB15589@lakrids.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04/17/2019 11:09 PM, Mark Rutland wrote:
> On Wed, Apr 17, 2019 at 10:15:35PM +0530, Anshuman Khandual wrote:
>> On 04/17/2019 07:51 PM, Mark Rutland wrote:
>>> On Wed, Apr 17, 2019 at 03:28:18PM +0530, Anshuman Khandual wrote:
>>>> On 04/15/2019 07:18 PM, Mark Rutland wrote:
>>>>> On Sun, Apr 14, 2019 at 11:29:13AM +0530, Anshuman Khandual wrote:
> 
>>>>>> +	spin_unlock(&init_mm.page_table_lock);
>>>>>
>>>>> What precisely is the page_table_lock intended to protect?
>>>>
>>>> Concurrent modification to kernel page table (init_mm) while clearing entries.
>>>
>>> Concurrent modification by what code?
>>>
>>> If something else can *modify* the portion of the table that we're
>>> manipulating, then I don't see how we can safely walk the table up to
>>> this point without holding the lock, nor how we can safely add memory.
>>>
>>> Even if this is to protect something else which *reads* the tables,
>>> other code in arm64 which modifies the kernel page tables doesn't take
>>> the lock.
>>>
>>> Usually, if you can do a lockless walk you have to verify that things
>>> didn't change once you've taken the lock, but we don't follow that
>>> pattern here.
>>>
>>> As things stand it's not clear to me whether this is necessary or
>>> sufficient.
>>
>> Hence lets take more conservative approach and wrap the entire process of
>> remove_pagetable() under init_mm.page_table_lock which looks safe unless
>> in the worst case when free_pages() gets stuck for some reason in which
>> case we have bigger memory problem to deal with than a soft lock up.
> 
> Sorry, but I'm not happy with _any_ solution until we understand where
> and why we need to take the init_mm ptl, and have made some effort to
> ensure that the kernel correctly does so elsewhere. It is not sufficient
> to consider this code in isolation.

We will have to take the kernel page table lock to prevent assumption regarding
present or future possible kernel VA space layout. Wrapping around the entire
remove_pagetable() will be at coarse granularity but I dont see why it should
not sufficient atleast from this particular tear down operation regardless of
how this might affect other kernel pgtable walkers.

IIUC your concern is regarding other parts of kernel code (arm64/generic) which
assume that kernel page table wont be changing and hence they normally walk the
table without holding pgtable lock. Hence those current pgtabe walker will be
affected after this change.

> 
> IIUC, before this patch we never clear non-leaf entries in the kernel
> page tables, so readers don't presently need to take the ptl in order to
> safely walk down to a leaf entry.

Got it. Will look into this.

> 
> For example, the arm64 ptdump code never takes the ptl, and as of this
> patch it will blow up if it races with a hot-remove, regardless of
> whether the hot-remove code itself holds the ptl.

Got it. Are there there more such examples where this can be problematic. I
will be happy to investigate all such places and change/add locking scheme
in there to make them work with memory hot remove.

> 
> Note that the same applies to the x86 ptdump code; we cannot assume that
> just because x86 does something that it happens to be correct.

I understand. Will look into other non-x86 platforms as well on how they are
dealing with this.

> 
> I strongly suspect there are other cases that would fall afoul of this,
> in both arm64 and generic code.

Will start looking into all such possible cases both on arm64 and generic.
Mean while more such pointers would be really helpful.

