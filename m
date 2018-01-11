Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 562596B0253
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 20:27:25 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id r8so1521973pgq.1
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 17:27:25 -0800 (PST)
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id ay5si12795935plb.66.2018.01.10.17.27.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jan 2018 17:27:24 -0800 (PST)
Message-ID: <5A56BD66.8040607@huawei.com>
Date: Thu, 11 Jan 2018 09:27:02 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC] mm: why vfree() do not free page table memory?
References: <5A4603AB.8060809@huawei.com>
In-Reply-To: <5A4603AB.8060809@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel
 Gorman <mgorman@techsingularity.net>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "Wujiangtao (A)" <wu.wujiangtao@huawei.com>, "Qiuchangqi (Lion, Euler Dept )" <qiuchangqi.qiu@huawei.com>

On 2017/12/29 16:58, Xishi Qiu wrote:

> When calling vfree(), it calls unmap_vmap_area() to clear page table,
> but do not free the memory of page table, why? just for performance?
> 
> If a driver use vmalloc() and vfree() frequently, we will lost much
> page table memory, maybe oom later.
> 
> Thanks,
> Xishi Qiu
> 

ping

> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
