Message-ID: <3ED49A14.2020704@aitel.hist.no>
Date: Wed, 28 May 2003 13:14:28 +0200
From: Helge Hafting <helgehaf@aitel.hist.no>
MIME-Version: 1.0
Subject: Re: 2.5.67-mm1 bootcrash, possibly IDE or RAID
References: <20030408042239.053e1d23.akpm@digeo.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2.5.69-mm8 is fine, 2.5.67-mm1 dies before mounting anything read-write.

The early kernel boot is fine, the penguin appear,
a bunch of the usual messages scroll by too fast to read,
and then it hangs.

The kernel is UP, with preempt & devfs.  All filesystems
are ext2. This kernel has no module support.

Root is on raid-1, there are two
ide disks connected to this controller on separate cables:
00:02.5 IDE interface: Silicon Integrated Systems [SiS] 5513 [IDE]

Here's the decoded crash, written down by hand:
<stuff scrolled off screen>
bio_endio
_end_that_request_first
ide_end_request
ide_dma_intr
ide_intr
ide_dma_intr
handle_IRQ_event
do_IRQ
default_idle
default_idle
common_interrupt
default_idle
default_idle
default_idle
cpu_idle
rest_init
start_kernel
unknown_bootoption
<0>Kwrnel Panic fatal exception in interrupt
in interrupt - not syncing

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
