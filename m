Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0764F6B0071
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 06:06:36 -0400 (EDT)
From: "Wu, Xia" <xia.wu@intel.com>
Date: Fri, 8 Oct 2010 18:04:44 +0800
Subject: RE: [PATCH] bdi: use deferable timer for sync_supers task
Message-ID: <A24AE1FFE7AEC5489F83450EE98351BF227AB58D43@shsmsx502.ccr.corp.intel.com>
References: <20101008083514.GA12402@ywang-moblin2.bj.intel.com>
 <20101008092520.GB5426@lst.de>
In-Reply-To: <20101008092520.GB5426@lst.de>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@lst.de>, Yong Wang <yong.y.wang@linux.intel.com>
Cc: Jens Axboe <jaxboe@fusionio.com>, Artem Bityutskiy <Artem.Bityutskiy@nokia.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Fri, Oct 08, 2010 at 04:35:14PM +0800, Yong Wang wrote:
> > sync_supers task currently wakes up periodically for superblock
> > writeback. This hurts power on battery driven devices. This patch
> > turns this housekeeping timer into a deferable timer so that it
> > does not fire when system is really idle.

> How long can the timer be defereed?  We can't simply stop writing
> out data for a long time.  I think the current timer value should be
> the upper bound, but allowing to fire earlier to run during the
> same wakeup cycle as others is fine.

If the system is in sleep state, this timer can be deferred to the next wak=
e-up interrupt.
If the system is busy, this timer will fire at the scheduled time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
