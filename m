Date: Wed, 28 May 2003 04:13:45 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.67-mm1 bootcrash, possibly IDE or RAID
Message-ID: <20030528111345.GU8978@holomorphy.com>
References: <20030408042239.053e1d23.akpm@digeo.com> <3ED49A14.2020704@aitel.hist.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3ED49A14.2020704@aitel.hist.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Helge Hafting <helgehaf@aitel.hist.no>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 28, 2003 at 01:14:28PM +0200, Helge Hafting wrote:
> 2.5.69-mm8 is fine, 2.5.67-mm1 dies before mounting anything read-write.
> The early kernel boot is fine, the penguin appear,
> a bunch of the usual messages scroll by too fast to read,
> and then it hangs.
> The kernel is UP, with preempt & devfs.  All filesystems
> are ext2. This kernel has no module support.
> Root is on raid-1, there are two
> ide disks connected to this controller on separate cables:
> 00:02.5 IDE interface: Silicon Integrated Systems [SiS] 5513 [IDE]

Well, bugs were fixed since 2.5.67-mm1. Just upgrade to the most recent
kernel (2.5.70-mm1).


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
