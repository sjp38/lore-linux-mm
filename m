Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <helgehaf@aitel.hist.no>) (for <akpm@digeo.com>)
	(for <linux-kernel@vger.kernel.org>) (for <linux-mm@kvack.org>) By
	tone With Smtp ; Thu, 5 Jun 2003 11:53:51 +1000
From: Neil Brown <neilb@cse.unsw.edu.au>
Date: Thu, 5 Jun 2003 11:53:51 +1000
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16094.41647.614418.452777@notabene.cse.unsw.edu.au>
Subject: Re: 2.5.70-mm4
In-Reply-To: message from Helge Hafting on Wednesday June 4
References: <20030603231827.0e635332.akpm@digeo.com>
	<20030604211216.GA2436@hh.idb.hist.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Helge Hafting <helgehaf@aitel.hist.no>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday June 4, helgehaf@aitel.hist.no wrote:
> Raid-1 seems to work in 2.5.70-mm4, but raid-0 still fail.
> 
> Trying to boot with raid-0 autodetect yields a long string of:
> Slab error in cache_free_debugcheck
> cache 'size-32' double free or
> memory after object overwritten.
> (Is this something "Page alloc debugging"may be used for?)
> kfree+0xfc/0x330
> raid0_run
> raid0_run
> printk
> blk_queue_make_request
> do_md_run
> md_ioctl
> dput
> blkdev_ioctl
> sys_ioctl
> syscall_call
> 
> I get a ton of these, in between normal
> initialization messages.  Then the thing
> dies with a panic due to exception in interrupt.
> 
> This is a monolithic smp preempt kernel on a dual celeron.
> The disks are scsi, the filesystems ext2.  There is one
> raid-0 array and two raid-1 arrays, as well as some
> ordinary partitions.  Root is on raid-1.
> 
> Helge Hafting

grrr... I thought I had that right...

You need to remove the two calls to 'kfree' at the end of 
create_strip_zones.

I have jsut sent some patches to Linus (and linux-raid@vger) which
will update his tree to include this fix.

NeilBrown
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
