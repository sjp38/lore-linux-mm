Date: Thu, 9 Dec 2004 10:36:44 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Fwd: Re: Plzz help me regarding HIGHMEM (PAE) confusion in Linux-2.4 ???
Message-ID: <20041209183644.GB2714@holomorphy.com>
References: <20041209125425.85749.qmail@web53901.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041209125425.85749.qmail@web53901.mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Fawad Lateef <fawad_lateef@yahoo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Dec 09, 2004 at 04:54:25AM -0800, Fawad Lateef wrote:
> but what I saw is that the pgd is loaded in cr3 when
> the switch_mm takes place in the scheduling of
> process. And PGD is of 64bit size ................ can
> u please explain this ???

The pgd is not loaded into %cr3, only its address.


On Thu, Dec 09, 2004 at 04:54:25AM -0800, Fawad Lateef wrote:
> Actually I m concerned in accessing 4GB to 32GB for
> ramdisk, and when I used to access those through
> kmap_atomic in a single module system crashes after
> passing the first 4GB of RAM (screen shows garbage and
> then system crashes), I got to know that a process can
> only access 4GB, so I created kernel threads for each
> 4GB and allocated struct mm_struct entry to that
> through mm_alloc function and then assigned that to
> the task_struct->active_mm to each thread, (in thread
> before mm_alloc I called daemonize too)......... 
> Now I think that all threads are now different
> processes, but the system crashing behaviour is the
> same ............. kernel is 2.4.25 
> Can u plz suggest me some way of doing this ???

There is only one kernel address space. You are probably actually
trying to write blkdev-highmem, but it would be far easier to populate
a ramfs at boot instead of using a ramdisk.

The ramdisk block driver is crusty and probably qualifies as broken
on 32-bit due to the resource scalability issues. It would be much
easier (and you'd encounter much less negative feedback) using ramfs or
a 64-bit architecture.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
