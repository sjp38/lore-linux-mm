Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01607C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:38:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B34E52190A
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:38:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B34E52190A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 511CE8E0002; Wed, 13 Feb 2019 09:38:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 497258E0001; Wed, 13 Feb 2019 09:38:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33A0E8E0002; Wed, 13 Feb 2019 09:38:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C98178E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:38:42 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id 39so1107094edq.13
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 06:38:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=jykjv/XUwg9DHvLaqE9lwGJzkYL1Tymty7cylnLGjdM=;
        b=Hga2sW4g9bX6hZ2L3vSBuNLANmMQAfrzcRS5B32LfnjqJ1ko0shiJ0aV5TwlTbpYs1
         qVNP//dD5IZpcKK/iTAKcrRyUIiWRESQp+/5tKk7i4RyAwb0uga3j5LBS4iK0aKqvqLv
         Ng8BNi1vm68MxvVpkJ4BnnWWP6xd5YDAYLvh7vBJEY6bMnbkcA98iOWmhwciQVFxxLVO
         xqiCBHMeqMfcszJBMFLbj55NxbEpSyL/wq1mqMEADNl/ModhITdfPa1lupC9t+Y2Tm7M
         z+4WZj6b71v9smkkEA+gmMVWG3SmGIZ62nKMztPKxe6wh4ydP9VyC9G5DU6unJRUSjZj
         6DCw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: AHQUAubPr9vp5xVVPUtWSqD+u2tqlZ/LqUcy+LcsqDgOQZA5TPQdZDwo
	iKNEQeKry4nc65XwNfbAM25jZkK+xAwLt1FazKzU0XpuPYV59+R5KoseL+Dw9843/G2WtIDncs0
	GCYTgBINGOCNpRNOOxKphOASXXNM4WJC4dUiQV+7108fhmea1UoakxhVjdKQPKwNlOQ==
X-Received: by 2002:a17:906:5612:: with SMTP id f18mr635809ejq.44.1550068722320;
        Wed, 13 Feb 2019 06:38:42 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYHOXEEg2A7XmtCxM83bJXeWi6X9JKft+XcaVgY3Ixgul5QX1LKo+pi7+LlogeOlbMTjsRh
X-Received: by 2002:a17:906:5612:: with SMTP id f18mr635748ejq.44.1550068721304;
        Wed, 13 Feb 2019 06:38:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550068721; cv=none;
        d=google.com; s=arc-20160816;
        b=byzzXRYvVywj5LqHwwyYHyaBEdVEwdhiBfaHh4w27yk/+QPnFH2JrhTVNgA789558F
         uXcl3NbTefsJevV2n9Pac1GwB0GapNy38HceusXuMqArch9TaRjU2V0+5b2OqBFmNNQi
         bOQ23YwcEbzx72Ljc8FbU/HomPkK+MUT77Vzh9IgfFSNh9UNUam99jWKPl7wn1JZFwpp
         IHK4RWt8URxk8ey48kBk+cVlRoK5ABL9YDBLHs3K7Dg6TMtyHFUB2T14v5dti7HCZKzv
         GOrTevMOhxS1XLhfYUf+9A7tyxuQMniVAacQFmob3srl0m6D7PwocrdK8OcWbNh0d7ir
         lv0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=jykjv/XUwg9DHvLaqE9lwGJzkYL1Tymty7cylnLGjdM=;
        b=JWpC5yAsTPeiKFyF2NG/i+FnzvwLl0T3NxmHIhHGiVqtlgQ5zbj/8woN4lGt9hjE8V
         FAc7bnkeVc8TJianzhVQHX5wUsGM4MR/Ao55XHUDXTJYL2JCykO3dLP1GnVxxwqWBfqt
         Vay35JG6fDBDotAKG6ayfG7e2KmAAddbw5dxRQQdYMprY6mgaH0FbZ0VskDC95wZ+Z6m
         9S5JbZUfgLpKyTnxy+VH7uz+dacCHUG1gpplI0faVS4qkTPxuphSgptKFl0Ib4nnYbQI
         PSck5c/uwketAHqfwrAjGbn3od0LqnJmN7r4RA7gmotmLPybe93G7AZVywdvdPl2tbkK
         NbyA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d14si2253413ede.302.2019.02.13.06.38.40
        for <linux-mm@kvack.org>;
        Wed, 13 Feb 2019 06:38:41 -0800 (PST)
Received-SPF: pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3B63780D;
	Wed, 13 Feb 2019 06:38:40 -0800 (PST)
Received: from [10.1.196.75] (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 714513F557;
	Wed, 13 Feb 2019 06:38:39 -0800 (PST)
Subject: Re: [PATCH] mm: Fix __dump_page() for poisoned pages
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org,
 linux-kernel@vger.kernel.org
References: <dbbcd36ca1f045ec81f49c7657928a1cdf24872b.1550065120.git.robin.murphy@arm.com>
 <20190213142308.GQ4525@dhcp22.suse.cz>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <05a91777-3b95-14a9-c959-a12b25a9b26f@arm.com>
Date: Wed, 13 Feb 2019 14:38:37 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190213142308.GQ4525@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 13/02/2019 14:23, Michal Hocko wrote:
> On Wed 13-02-19 13:40:49, Robin Murphy wrote:
>> Evaluating page_mapping() on a poisoned page ends up dereferencing junk
>> and making PF_POISONED_CHECK() considerably crashier than intended. Fix
>> that by not inspecting the mapping until we've determined that it's
>> likely to be valid.
> 
> Has this ever triggered? I am mainly asking because there is no usage of
> mapping so I would expect that the compiler wouldn't really call
> page_mapping until it is really used.

A function call is a sequence point, so any compiler that did that would 
be totally broken.

The crash looks like this (now from an explicit dump_page() call before 
it happens naturally deep within pfn_to_nid()):
-----
[  107.147056] Unable to handle kernel NULL pointer dereference at 
virtual address 0000000000000006
[  107.155774] Mem abort info:
[  107.158546]   ESR = 0x96000005
[  107.161572]   Exception class = DABT (current EL), IL = 32 bits
[  107.167437]   SET = 0, FnV = 0
[  107.170460]   EA = 0, S1PTW = 0
[  107.173568] Data abort info:
[  107.176419]   ISV = 0, ISS = 0x00000005
[  107.180218]   CM = 0, WnR = 0
[  107.183151] user pgtable: 4k pages, 39-bit VAs, pgdp = 00000000c2f6ac38
[  107.189702] [0000000000000006] pgd=0000000000000000, pud=0000000000000000
[  107.196430] Internal error: Oops: 96000005 [#1] PREEMPT SMP
[  107.201942] Modules linked in:
[  107.204962] CPU: 2 PID: 491 Comm: bash Not tainted 5.0.0-rc1+ #1
[  107.210903] Hardware name: ARM LTD ARM Juno Development Platform/ARM 
Juno Development Platform, BIOS EDK II Dec 17 2018
[  107.221576] pstate: 00000005 (nzcv daif -PAN -UAO)
[  107.226321] pc : page_mapping+0x18/0x118
[  107.230200] lr : __dump_page+0x1c/0x398
[  107.233990] sp : ffffff8011a53c30
[  107.237265] x29: ffffff8011a53c30 x28: ffffffc039b6ec00
[  107.242520] x27: 0000000000000000 x26: 0000000000000000
[  107.247775] x25: 0000000056000000 x24: 0000000000000015
[  107.253029] x23: ffffff80114d8b18 x22: 0000000000000022
[  107.258283] x21: ffffffc03538ec38 x20: ffffff8011082e78
[  107.263537] x19: ffffffbf20000000 x18: 0000000000000000
[  107.268790] x17: 0000000000000000 x16: 0000000000000000
[  107.274044] x15: 0000000000000000 x14: 0000000000000000
[  107.279297] x13: 0000000000000000 x12: 0000000000000030
[  107.284550] x11: 0000000000000030 x10: 0101010101010101
[  107.289804] x9 : ff7274615e68726c x8 : 7f7f7f7f7f7f7f7f
[  107.295057] x7 : feff64756e6c6471 x6 : 0000000000008080
[  107.300310] x5 : 0000000000000000 x4 : 0000000000000000
[  107.305564] x3 : ffffffc039b6ec00 x2 : fffffffffffffffe
[  107.310817] x1 : ffffffffffffffff x0 : fffffffffffffffe
[  107.316072] Process bash (pid: 491, stack limit = 0x000000004ebd4ecd)
[  107.322442] Call trace:
[  107.324858]  page_mapping+0x18/0x118
[  107.328392]  __dump_page+0x1c/0x398
[  107.331840]  dump_page+0xc/0x18
[  107.334945]  remove_store+0xbc/0x120
[  107.338479]  dev_attr_store+0x18/0x28
[  107.342103]  sysfs_kf_write+0x40/0x50
[  107.345722]  kernfs_fop_write+0x130/0x1d8
[  107.349687]  __vfs_write+0x30/0x180
[  107.353134]  vfs_write+0xb4/0x1a0
[  107.356410]  ksys_write+0x60/0xd0
[  107.359686]  __arm64_sys_write+0x18/0x20
[  107.363565]  el0_svc_common+0x94/0xf8
[  107.367184]  el0_svc_handler+0x68/0x70
[  107.370890]  el0_svc+0x8/0xc
[  107.373737] Code: f9400401 d1000422 f240003f 9a801040 (f9400402)
[  107.379766] ---[ end trace cdb5eb5bf435cecb ]---
-----

While after this patch, DEBUG_VM works as intended:
-----
[   46.835963] page:ffffffbf20000000 is uninitialized and poisoned
[   46.835970] raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff 
ffffffffffffffff
[   46.849520] raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff 
ffffffffffffffff
[   46.857194] page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
[   46.863170] ------------[ cut here ]------------
[   46.867736] kernel BUG at ./include/linux/mm.h:1006!
[   46.872646] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
[   46.878071] Modules linked in:
[   46.881092] CPU: 1 PID: 483 Comm: bash Not tainted 5.0.0-rc1+ #3
[   46.887032] Hardware name: ARM LTD ARM Juno Development Platform/ARM 
Juno Development Platform, BIOS EDK II Dec 17 2018
[   46.897704] pstate: 40000005 (nZcv daif -PAN -UAO)
[   46.902449] pc : remove_store+0xbc/0x120
...
-----

Robin.

>> Fixes: 1c6fb1d89e73 ("mm: print more information about mapping in __dump_page")
>> Signed-off-by: Robin Murphy <robin.murphy@arm.com>
>> ---
>>   mm/debug.c | 4 +++-
>>   1 file changed, 3 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/debug.c b/mm/debug.c
>> index 0abb987dad9b..1611cf00a137 100644
>> --- a/mm/debug.c
>> +++ b/mm/debug.c
>> @@ -44,7 +44,7 @@ const struct trace_print_flags vmaflag_names[] = {
>>   
>>   void __dump_page(struct page *page, const char *reason)
>>   {
>> -	struct address_space *mapping = page_mapping(page);
>> +	struct address_space *mapping;
>>   	bool page_poisoned = PagePoisoned(page);
>>   	int mapcount;
>>   
>> @@ -58,6 +58,8 @@ void __dump_page(struct page *page, const char *reason)
>>   		goto hex_only;
>>   	}
>>   
>> +	mapping = page_mapping(page);
>> +
>>   	/*
>>   	 * Avoid VM_BUG_ON() in page_mapcount().
>>   	 * page->_mapcount space in struct page is used by sl[aou]b pages to
>> -- 
>> 2.20.1.dirty
>>
> 

