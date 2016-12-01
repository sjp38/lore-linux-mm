Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id AA5C46B025E
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 21:30:59 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id c21so50763966ioj.5
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 18:30:59 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id p205si32395399oif.74.2016.11.30.18.30.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Nov 2016 18:30:59 -0800 (PST)
Subject: Re: [PATCH] mm: Fix a NULL dereference crash while accessing
 bdev->bd_disk
References: <1480125982-8497-1-git-send-email-fangwei1@huawei.com>
 <20161128100718.GD2590@quack2.suse.cz> <583CE0C7.1040406@huawei.com>
 <20161130095104.GB20030@quack2.suse.cz>
From: Wei Fang <fangwei1@huawei.com>
Message-ID: <583F8B2D.8090908@huawei.com>
Date: Thu, 1 Dec 2016 10:30:05 +0800
MIME-Version: 1.0
In-Reply-To: <20161130095104.GB20030@quack2.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, hch@infradead.org, linux-mm@kvack.org, stable@vger.kernel.org, Jens Axboe <axboe@kernel.dk>, Tejun Heo <tj@kernel.org>

Hi, Jan,

On 2016/11/30 17:51, Jan Kara wrote:
> On Tue 29-11-16 09:58:31, Wei Fang wrote:
>> Hi, Jan,
>>
>> On 2016/11/28 18:07, Jan Kara wrote:
>>> Good catch but I don't like sprinkling checks like this into the writeback
>>> code and furthermore we don't want to call into writeback code when block
>>> device is in the process of being destroyed which is what would happen with
>>> your patch. That is a bug waiting to happen...
>>
>> Agreed. Need another way to fix this problem. I looked through the
>> writeback cgroup code in __filemap_fdatawrite_range(), found if we
>> turn on CONFIG_CGROUP_WRITEBACK, a new crash will happen.
> 
> OK, can you test with attached patch please? Thanks!

I've tested this patch with linux-next about 2 hours, and all goes well.
Without this patch, kernel crashes in minutes.

Thanks,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
