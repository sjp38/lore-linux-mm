Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E45D16B0260
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 04:51:06 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id u144so49614058wmu.1
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 01:51:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h70si6192254wme.114.2016.11.30.01.51.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Nov 2016 01:51:05 -0800 (PST)
Date: Wed, 30 Nov 2016 10:51:04 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: Fix a NULL dereference crash while accessing
 bdev->bd_disk
Message-ID: <20161130095104.GB20030@quack2.suse.cz>
References: <1480125982-8497-1-git-send-email-fangwei1@huawei.com>
 <20161128100718.GD2590@quack2.suse.cz>
 <583CE0C7.1040406@huawei.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="HlL+5n6rz5pIUxbD"
Content-Disposition: inline
In-Reply-To: <583CE0C7.1040406@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Fang <fangwei1@huawei.com>
Cc: Jan Kara <jack@suse.cz>, akpm@linux-foundation.org, hannes@cmpxchg.org, hch@infradead.org, linux-mm@kvack.org, stable@vger.kernel.org, Jens Axboe <axboe@kernel.dk>, Tejun Heo <tj@kernel.org>


--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue 29-11-16 09:58:31, Wei Fang wrote:
> Hi, Jan,
> 
> On 2016/11/28 18:07, Jan Kara wrote:
> > Good catch but I don't like sprinkling checks like this into the writeback
> > code and furthermore we don't want to call into writeback code when block
> > device is in the process of being destroyed which is what would happen with
> > your patch. That is a bug waiting to happen...
> 
> Agreed. Need another way to fix this problem. I looked through the
> writeback cgroup code in __filemap_fdatawrite_range(), found if we
> turn on CONFIG_CGROUP_WRITEBACK, a new crash will happen.

OK, can you test with attached patch please? Thanks!

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--HlL+5n6rz5pIUxbD
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0001-block-protect-iterate_bdevs-against-concurrent-close.patch"


--HlL+5n6rz5pIUxbD--
