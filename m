Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BBC4B6B006A
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 05:25:28 -0400 (EDT)
Date: Fri, 8 Oct 2010 11:25:20 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] bdi: use deferable timer for sync_supers task
Message-ID: <20101008092520.GB5426@lst.de>
References: <20101008083514.GA12402@ywang-moblin2.bj.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101008083514.GA12402@ywang-moblin2.bj.intel.com>
Sender: owner-linux-mm@kvack.org
To: Yong Wang <yong.y.wang@linux.intel.com>
Cc: Jens Axboe <jaxboe@fusionio.com>, Christoph Hellwig <hch@lst.de>, Artem Bityutskiy <Artem.Bityutskiy@nokia.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xia.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Fri, Oct 08, 2010 at 04:35:14PM +0800, Yong Wang wrote:
> sync_supers task currently wakes up periodically for superblock
> writeback. This hurts power on battery driven devices. This patch
> turns this housekeeping timer into a deferable timer so that it
> does not fire when system is really idle.

How long can the timer be defereed?  We can't simply stop writing
out data for a long time.  I think the current timer value should be
the upper bound, but allowing to fire earlier to run during the
same wakeup cycle as others is fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
