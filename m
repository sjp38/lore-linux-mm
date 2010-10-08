Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 60B8F6B006A
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 06:05:32 -0400 (EDT)
Subject: Re: [PATCH] bdi: use deferable timer for sync_supers task
From: Artem Bityutskiy <Artem.Bityutskiy@nokia.com>
Reply-To: Artem.Bityutskiy@nokia.com
In-Reply-To: <20101008092520.GB5426@lst.de>
References: <20101008083514.GA12402@ywang-moblin2.bj.intel.com>
	 <20101008092520.GB5426@lst.de>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 08 Oct 2010 13:02:35 +0300
Message-ID: <1286532155.2095.52.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: ext Christoph Hellwig <hch@lst.de>
Cc: Yong Wang <yong.y.wang@linux.intel.com>, Jens Axboe <jaxboe@fusionio.com>, Wu Fengguang <fengguang.wu@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "xia.wu@intel.com" <xia.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2010-10-08 at 11:25 +0200, ext Christoph Hellwig wrote:
> On Fri, Oct 08, 2010 at 04:35:14PM +0800, Yong Wang wrote:
> > sync_supers task currently wakes up periodically for superblock
> > writeback. This hurts power on battery driven devices. This patch
> > turns this housekeeping timer into a deferable timer so that it
> > does not fire when system is really idle.
> 
> How long can the timer be defereed?  We can't simply stop writing
> out data for a long time.  I think the current timer value should be
> the upper bound, but allowing to fire earlier to run during the
> same wakeup cycle as others is fine.

Infinitely.

There are range hrtimers which can do exactly what you said - you
specify the hard and soft limits there.

-- 
Best Regards,
Artem Bityutskiy (D?N?N?N?D 1/4  D?D,N?N?N?DoD,D1)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
