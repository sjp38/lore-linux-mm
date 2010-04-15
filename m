Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 62E7C6B01F1
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 02:59:08 -0400 (EDT)
Date: Thu, 15 Apr 2010 16:58:58 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100415065858.GS2493@dastard>
References: <20100415133332.D183.A69D9226@jp.fujitsu.com>
 <20100415063219.GR2493@dastard>
 <20100415154328.D18F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100415154328.D18F.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 15, 2010 at 03:44:50PM +0900, KOSAKI Motohiro wrote:
> > > Now, kernel compile and/or backup operation seems keep nr_vmscan_write==0.
> > > Dave, can you please try to run your pageout annoying workload?
> > 
> > It's just as easy for you to run and observe the effects. Start with a VM
> > with 1GB RAM and a 10GB scratch block device:
> > 
> > # mkfs.xfs -f /dev/<blah>
> > # mount -o logbsize=262144,nobarrier /dev/<blah> /mnt/scratch
> > 
> > in one shell:
> > 
> > # while [ 1 ]; do dd if=/dev/zero of=/mnt/scratch/foo bs=1024k ; done
> > 
> > in another shell, if you have fs_mark installed, run:
> > 
> > # ./fs_mark -S0 -n 100000 -F -s 0 -d /mnt/scratch/0 -d /mnt/scratch/1 -d /mnt/scratch/3 -d /mnt/scratch/2 &
> > 
> > otherwise run a couple of these in parallel on different directories:
> > 
> > # for i in `seq 1 1 100000`; do echo > /mnt/scratch/0/foo.$i ; done
> 
> Thanks.
> 
> Unfortunately, I don't have unused disks. So, I'll try it at (probably)
> next week.

A filesystem on a loopback device will work just as well ;)

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
