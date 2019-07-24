Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BFF9C76194
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 08:33:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 182C221951
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 08:33:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 182C221951
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA6046B0008; Wed, 24 Jul 2019 04:33:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A56BC8E0003; Wed, 24 Jul 2019 04:33:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 91DEE8E0002; Wed, 24 Jul 2019 04:33:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 69B916B0008
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 04:33:24 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id q16so25323201otn.11
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 01:33:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=oitnFF/InWTMHJQSUazp84sh4LWSF8vLTtJQZuvirlk=;
        b=sgqOj14XOTLTDLTqUtCBRtpwfwlu8VORgrhXOHWnXJ+yxtfANKqe0NVEK4DdNa0o9A
         4HkTYiTTa0x7ISjfVD3nltDjWHFcb4ul+4+F8VCl4u+Z5/BzuOHw6IIhAiJw59kRWxUu
         cmUlxEArcTqa7T9G2xG6XCKPo+xXdW7FmYI+iWjkzf7Q006P7zc5rsh0HO6YfBovPW34
         pajUt8P2DzGtdJ9CNg/gGLXMiKBQ5TBl4mO4228veHHrZPM1CO5bheW2sMOATDnyy15j
         ffRVQZjcU4vfzlNvTI6BJAnWPISSf2F4Nmk737GzGV8p22DKK3O8MjRykGxabMSrpW1R
         ixww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of guohanjun@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=guohanjun@huawei.com
X-Gm-Message-State: APjAAAXlrNQIeRWCOUK4nPr/bqeR5ahO6d6yme9wQqIa2zriVvYk9pJp
	txjHD2GuxTZELl9NKJIRQIawIMq/4+Yt4rL2LjRtxTZrboIRU6hzhhCEQYRQmeRHSWpAGZeLcxG
	qEuX6UbSJxMrX/4ATvXwmvpYRakrysyY5UHT/5p7B2c2/m6kZ6mT2z8rm0rI/go3ddg==
X-Received: by 2002:aca:3158:: with SMTP id x85mr36348690oix.93.1563957204000;
        Wed, 24 Jul 2019 01:33:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzYcoRw6rCbsRxReNOg1RwgAM9Zz/pdB4JctL1iCmYgYk6R8dTBFVayq/pumMgwylRd2Hht
X-Received: by 2002:aca:3158:: with SMTP id x85mr36348655oix.93.1563957203323;
        Wed, 24 Jul 2019 01:33:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563957203; cv=none;
        d=google.com; s=arc-20160816;
        b=Sj14OV+6vgILV0sAqY4PDVynrg+Zi4NwRB3PYTWlMgOvHzHft9Vz9SYwn1bBX0GgqY
         bweOLGOd0InM+ytsO76btihfctzKFFZg4697Bguh1IY90aasnbiEkXsilg36fckCgjlR
         lwowAp3XQ3kN2iP7UyPo68RVetbrolKbzQrBZdRXjbWMpTJGYBYElm1lPGbFrFD5vEWA
         UHURBMU7osiBfMC3ANDfL1X+9sE+1oD3FGx5YEW/nHrzow2xkYZakdueYdhOsJM+ZAxR
         s05dFQ0JFcS8+qDm2NOHepOkYuQse9LP9kFUsE3MUcHuC7CizR5EHTXtyOMA3IOiA7BJ
         V0QQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=oitnFF/InWTMHJQSUazp84sh4LWSF8vLTtJQZuvirlk=;
        b=mx0Mt3/dYF3YSefSVJNlyy3Z87jUb9GK4kMtv9DsMM5WeUT59awU3H8izJug1eNURi
         DgjK9nlgdZwPKrDF9ol4pjqUolJ0+dI46pnds8gULhLbr8exQCtwQYfINyaay8aWih65
         aB5Bv41iHvuYgdh64fbMeLUb9/l3o5HulXl04Qyd1J4nhAxbd6V4ictLgbQOahi1HZWY
         suy7lZrvhDQ0Z072lsnON5rFdKrPnJdMUi8GEgpOGcNZdCKsNtPHemyzhwInJ3kprrtW
         8q9O2a/6bm4qSkt8UGp71DuNJ2+wnJX5HDUxBuSrgjFJDvbguKUc7Y9QGMDSp43//ZMS
         7hEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of guohanjun@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=guohanjun@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id d136si25600233oig.208.2019.07.24.01.33.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 01:33:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of guohanjun@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of guohanjun@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=guohanjun@huawei.com
Received: from DGGEMS403-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id D5579585EAE5EF849C02;
	Wed, 24 Jul 2019 16:33:18 +0800 (CST)
Received: from [127.0.0.1] (10.177.223.23) by DGGEMS403-HUB.china.huawei.com
 (10.3.19.203) with Microsoft SMTP Server id 14.3.439.0; Wed, 24 Jul 2019
 16:33:16 +0800
Subject: Re: [PATCH v12 2/2] mm: page_alloc: reduce unnecessary binary search
 in memblock_next_valid_pfn
To: Mike Rapoport <rppt@linux.ibm.com>
CC: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Catalin Marinas
	<catalin.marinas@arm.com>, <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>, Jia He <hejianet@gmail.com>, Andrew Morton
	<akpm@linux-foundation.org>, Will Deacon <will@kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
References: <1563861073-47071-1-git-send-email-guohanjun@huawei.com>
 <1563861073-47071-3-git-send-email-guohanjun@huawei.com>
 <20190723083353.GC4896@rapoport-lnx>
From: Hanjun Guo <guohanjun@huawei.com>
Message-ID: <868f90c7-a728-9eb3-7529-f5a8a501a76a@huawei.com>
Date: Wed, 24 Jul 2019 16:33:01 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:52.0) Gecko/20100101
 Thunderbird/52.5.0
MIME-Version: 1.0
In-Reply-To: <20190723083353.GC4896@rapoport-lnx>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.223.23]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/7/23 16:33, Mike Rapoport wrote:
> On Tue, Jul 23, 2019 at 01:51:13PM +0800, Hanjun Guo wrote:
>> From: Jia He <hejianet@gmail.com>
>>
>> After skipping some invalid pfns in memmap_init_zone(), there is still
>> some room for improvement.
>>
>> E.g. if pfn and pfn+1 are in the same memblock region, we can simply pfn++
>> instead of doing the binary search in memblock_next_valid_pfn.
>>
>> Furthermore, if the pfn is in a gap of two memory region, skip to next
>> region directly to speedup the binary search.
> How much speed up do you see with this improvements relatively to simple
> binary search in memblock_next_valid_pfn()?

The major speedup on my platform is the previous patch in this patch set,
not this one, I think it's related to sparse memory mode for different
platforms.

Thanks
Hanjun

>   

