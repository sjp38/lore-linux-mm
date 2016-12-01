Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5DD316B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 03:18:11 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id o3so37217256wjo.1
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 00:18:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n70si11032269wmd.139.2016.12.01.00.18.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Dec 2016 00:18:10 -0800 (PST)
Date: Thu, 1 Dec 2016 09:18:07 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: Fix a NULL dereference crash while accessing
 bdev->bd_disk
Message-ID: <20161201081807.GD12804@quack2.suse.cz>
References: <1480125982-8497-1-git-send-email-fangwei1@huawei.com>
 <20161128100718.GD2590@quack2.suse.cz>
 <583CE0C7.1040406@huawei.com>
 <20161130095104.GB20030@quack2.suse.cz>
 <583F8B2D.8090908@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <583F8B2D.8090908@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Fang <fangwei1@huawei.com>
Cc: Jan Kara <jack@suse.cz>, akpm@linux-foundation.org, hannes@cmpxchg.org, hch@infradead.org, linux-mm@kvack.org, stable@vger.kernel.org, Jens Axboe <axboe@kernel.dk>, Tejun Heo <tj@kernel.org>

On Thu 01-12-16 10:30:05, Wei Fang wrote:
> On 2016/11/30 17:51, Jan Kara wrote:
> > On Tue 29-11-16 09:58:31, Wei Fang wrote:
> >> Hi, Jan,
> >>
> >> On 2016/11/28 18:07, Jan Kara wrote:
> >>> Good catch but I don't like sprinkling checks like this into the writeback
> >>> code and furthermore we don't want to call into writeback code when block
> >>> device is in the process of being destroyed which is what would happen with
> >>> your patch. That is a bug waiting to happen...
> >>
> >> Agreed. Need another way to fix this problem. I looked through the
> >> writeback cgroup code in __filemap_fdatawrite_range(), found if we
> >> turn on CONFIG_CGROUP_WRITEBACK, a new crash will happen.
> > 
> > OK, can you test with attached patch please? Thanks!
> 
> I've tested this patch with linux-next about 2 hours, and all goes well.
> Without this patch, kernel crashes in minutes.

Good. Thanks for testing! I'll send the patch for inclusion.

								hONZA
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
