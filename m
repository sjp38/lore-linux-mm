Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08662C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 07:54:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B5DFD2087C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 07:54:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5DFD2087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 502438E0003; Thu, 14 Mar 2019 03:54:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B0F08E0001; Thu, 14 Mar 2019 03:54:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 39F7D8E0003; Thu, 14 Mar 2019 03:54:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id F3BB98E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 03:54:21 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id n84so2027722oia.14
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 00:54:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=ZvARq4cooloLaUlA1LL1tH8m0FIn496kVGJBlnp8BCg=;
        b=rNvHadQFkNCANtRgTTlrRFdqeU8Z62hWWQevR6L51iGUlfSFDhSVNapnwR5Wcthk8v
         7sUtXLcwCLGAP6WlDgb7nNuIHZKkwWnlxNzx4RRFLb3mM7wITP46uZpRRujDK6TzJrfY
         1pDnGcbuM/Cru2p63dsDxyvb2erIgDwy9NcaMbZEhaiDZVyFr3w/mK8nrOo7c4e3SRCh
         wQGuwCuIkrnQzckMuJbWUyVEMBqzUfP04SGds5iJkyIwYbc4NQSSFwun6XsynHJolB2V
         c+foFbZQLYWBi+cj0pPAXPRPhkycqTPwb73OTwNT7Px4ANEojWithPgzNcpkEC39CmGC
         OokA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: APjAAAUCpJOJlK6mPxAjXK0wXh4mXPfoTVEGKiL9XU1mE7kQHqZA6W7h
	i/59Zn6EBYjwvgFAP3BlZ/yDPmL3eS9oLHbx5d+9TLbavvYwML16UaKqlcjPdkittDfJPndVpJO
	rAYC5AMP5codj+jyXcfadKNzWErIPTJBrFO0hhF1pYilkzD2/oJKg1I5e24/EI9N9Kw==
X-Received: by 2002:aca:d4d6:: with SMTP id l205mr1306629oig.73.1552550061598;
        Thu, 14 Mar 2019 00:54:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzR3MM/szNmfYjJ6C2+/gwkIavNCwvfa1SYSTYbnDKh13NKo0C3y/yYf/J/Ho/ap2VWIwYe
X-Received: by 2002:aca:d4d6:: with SMTP id l205mr1306583oig.73.1552550060685;
        Thu, 14 Mar 2019 00:54:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552550060; cv=none;
        d=google.com; s=arc-20160816;
        b=Hz9NXLEnsmb+ifTKx4q+mSBQa0Ls0M7HEQ8FwdmqADtWudFrm8FizV5Un9cUy7tDht
         jxsrWnWBDv4dAZEcPh1AIzKCahAT/E9igXL/Gf28WXFAhr1fy09otTbv5X2tb1nMZOt2
         Ub4MVDJ0ISYTKDVZX7Na5LuOiAWbb4JiEkGj7yBWaGAmei5iZwKfPpfeZyYOUkFjtC1s
         gN6Wcw+w1+Ey4kw6R2LMOfZ1UEXkbnVEBJLoRR8yi7/ZTBrekPPNtbi1DO/5n3Plgjsr
         PNh1MeIP2NASW50YM8V1GO6nxvfUm44wKLFSkCt9RDCKtcPwXM+Tj/qBfm/0SjjUiS2C
         mz4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=ZvARq4cooloLaUlA1LL1tH8m0FIn496kVGJBlnp8BCg=;
        b=NJyc3DzWQ48WuMlZrQBJ+6uAeit9H84B7znCG0f7covCP5FoO8rYfv2S93FzFkSGaD
         x5GuYLCtw36Wa4UKJE0Cly/5ip2glD2LuUj5smtQa4tuBBCtmvrNKi2yj/TfCQ6h9xmf
         U7VFsFEY6klYe7qJlVL0c2BK8HAwvPt6WzyFJdnzsJJwapfEV1sNo5okDpDZwkQ7KlH/
         rIvkGTEbM7drhX2PsZIiwZtovgnEXALKJjDklxlO1lemdNEGfFVaBZHuA0VNjyU3u5Zr
         QmTqF4rjDyeSPjLCBPA026Nlk7wo/6nWqwfo9dVE+po1haGF/nh+lmYCYICsHkiAz+gx
         jnMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id p83si5820315oih.196.2019.03.14.00.54.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 00:54:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS408-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 0EBDC5ABE2909F18C4D8;
	Thu, 14 Mar 2019 15:54:15 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS408-HUB.china.huawei.com
 (10.3.19.208) with Microsoft SMTP Server id 14.3.408.0; Thu, 14 Mar 2019
 15:54:10 +0800
Message-ID: <5C8A08A1.3090403@huawei.com>
Date: Thu, 14 Mar 2019 15:54:09 +0800
From: zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
CC: Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>, "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, Linux Memory Management List
	<linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins
	<hughd@google.com>
Subject: Re: [Qestion] Hit a WARN_ON_ONCE in try_to_unmap_one when runing
 syzkaller
References: <5C87D848.7030802@huawei.com> <20190314062757.GA27899@hori.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20190314062757.GA27899@hori.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/3/14 14:27, Naoya Horiguchi wrote:
> Hi,
>
> On Wed, Mar 13, 2019 at 12:03:20AM +0800, zhong jiang wrote:
> ...
>> Minchan has changed the conditon check from  BUG_ON  to WARN_ON_ONCE in try_to_unmap_one.
>> However,  It is still an abnormal condition when PageSwapBacked is not equal to PageSwapCache.
>>
>> But Is there any case it will meet the conditon in the mainline.
>>
>> It is assumed that PageSwapBacked(page) is true in the anonymous page,   This is to say,  PageSwapcache
>> is false. however,  That is impossible because we will update the pte for hwpoison entry.
>>
>> Because page is locked ,  Its page flags should not be changed except for PageSwapBacked
> try_to_unmap_one() from hwpoison_user_mappings() could reach the
> WARN_ON_ONCE() only if TTU_IGNORE_HWPOISON is set, because PageHWPoison()
> is set at the beginning of memory_failure().
>
> Clearing TTU_IGNORE_HWPOISON might happen on the following two paths:
>
>   static bool hwpoison_user_mappings(struct page *p, unsigned long pfn,
>                                     int flags, struct page **hpagep)
>   {
>       ...
>   
>       if (PageSwapCache(p)) {
>               pr_err("Memory failure: %#lx: keeping poisoned page in swap cache\n",
>                       pfn);
>               ttu |= TTU_IGNORE_HWPOISON;
>       }
>       ...
>
>       mapping = page_mapping(hpage);                                                                           
>       if (!(flags & MF_MUST_KILL) && !PageDirty(hpage) && mapping &&                                           
>           mapping_cap_writeback_dirty(mapping)) {                                                              
>               if (page_mkclean(hpage)) {                                                                       
>                       SetPageDirty(hpage);                                                                     
>               } else {                                                                                         
>                       kill = 0;                                                                                
>                       ttu |= TTU_IGNORE_HWPOISON;                                                              
>                       pr_info("Memory failure: %#lx: corrupted page was clean: dropped without side effects\n",
>                               pfn);                                                                            
>               }                                                                                                
>       }                                                                                                        
>       ...
>
>       unmap_success = try_to_unmap(hpage, ttu);
>       ...
>
> So either of the above "ttu |= TTU_IGNORE_HWPOISON" should be executed.
> I'm not sure which one, but both paths show printk messages, so if you
> could have kernel message log, that might help ...
Thank you for your response.

Unfortunately, I lost the printk log. I was looking for it before and support us for further analysis.

It's very weird to get there. Assume that TTU_IGNORE_HWPOSISON is set. There is the two case.

First, PageSwapCache is set and page has been locked. Theoretically WARN_ON_ONCE should not be triggered.
Second, We should assume the page belongs to file page.:-(

I will go on reproducing the issue and get the printk message log.

Thanks
zhong jiang
> Thanks,
> Naoya Horiguchi
>
> .
>


