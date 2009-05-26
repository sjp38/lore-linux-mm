Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 91F116B005A
	for <linux-mm@kvack.org>; Tue, 26 May 2009 19:42:44 -0400 (EDT)
Date: Tue, 26 May 2009 16:42:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] readahead:add blk_run_backing_dev
Message-Id: <20090526164252.0741b392.akpm@linux-foundation.org>
In-Reply-To: <20090522023323.GA10864@localhost>
References: <6.0.0.20.2.20090518183752.0581fdc0@172.19.0.2>
	<20090518175259.GL4140@kernel.dk>
	<20090520025123.GB8186@localhost>
	<6.0.0.20.2.20090521145005.06f81fe0@172.19.0.2>
	<20090522010538.GB6010@localhost>
	<6.0.0.20.2.20090522102551.0705aea0@172.19.0.2>
	<20090522023323.GA10864@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: hifumi.hisashi@oss.ntt.co.jp, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>

On Fri, 22 May 2009 10:33:23 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> > I tested above patch, and I got same performance number.
> > I wonder why if (PageUptodate(page)) check is there...
> 
> Thanks!  This is an interesting micro timing behavior that
> demands some research work.  The above check is to confirm if it's
> the PageUptodate() case that makes the difference. So why that case
> happens so frequently so as to impact the performance? Will it also
> happen in NFS?
> 
> The problem is readahead IO pipeline is not running smoothly, which is
> undesirable and not well understood for now.

The patch causes a remarkably large performance increase.  A 9%
reduction in time for a linear read?  I'd be surprised if the workload
even consumed 9% of a CPU, so where on earth has the kernel gone to?

Have you been able to reproduce this in your testing?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
