Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 587AF280281
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 04:16:04 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id i6so12556797wre.6
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 01:16:04 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z35si3669417wrc.232.2018.01.17.01.16.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Jan 2018 01:16:02 -0800 (PST)
Subject: Re: [RFC] mm: why vfree() do not free page table memory?
References: <5A4603AB.8060809@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0ffd113e-84da-bd49-2b63-3d27d2702580@suse.cz>
Date: Wed, 17 Jan 2018 10:16:01 +0100
MIME-Version: 1.0
In-Reply-To: <5A4603AB.8060809@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "Wujiangtao (A)" <wu.wujiangtao@huawei.com>

On 12/29/2017 09:58 AM, Xishi Qiu wrote:
> When calling vfree(), it calls unmap_vmap_area() to clear page table,
> but do not free the memory of page table, why? just for performance?

I guess it's expected that the free virtual range and associated page
tables it might be reused later.

> If a driver use vmalloc() and vfree() frequently, we will lost much
> page table memory, maybe oom later.

If it's reused, then not really.

Did you notice an actual issue, or is this just theoretical concern.

> Thanks,
> Xishi Qiu
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
