Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EB0BD6B0047
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 19:06:27 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7VMlCS6014375
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 18:47:12 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7VN6PFY140268
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 19:06:25 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7VN6P1a029128
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 19:06:25 -0400
Subject: Re: [PATCH 01/10] Replace ioctls with sysfs interface
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1281374816-904-2-git-send-email-ngupta@vflare.org>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>
	 <1281374816-904-2-git-send-email-ngupta@vflare.org>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Tue, 31 Aug 2010 16:06:23 -0700
Message-ID: <1283295983.7023.77.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@linuxdriverproject.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-08-09 at 22:56 +0530, Nitin Gupta wrote:
> Creates per-device sysfs nodes in /sys/block/zram<id>/
> Currently following stats are exported:
>  - disksize
>  - num_reads
>  - num_writes
>  - invalid_io
>  - zero_pages
>  - orig_data_size
>  - compr_data_size
>  - mem_used_total
> 
> By default, disksize is set to 0. So, to start using
> a zram device, fist write a disksize value and then
> initialize device by writing any positive value to
> initstate. For example:
> 
>         # initialize /dev/zram0 with 50MB disksize
>         echo 50*1024*1024 | bc > /sys/block/zram0/disksize
>         echo 1 > /sys/block/zram0/initstate
> 
> When done using a disk, issue reset to free its memory
> by writing any positive value to reset node:
> 
>         echo 1 > /sys/block/zram0/reset

Maybe I'm just a weirdo, but I don't really use modules much.  That
effectively means that I'm stuck at boot with one zram device.

Making it a read-only module param also means that someone can't add a
second at runtime while the first is still in use.

It doesn't seem to be used very pervasively, but there is a
module_param_cb() function so you can register callbacks when the param
gets updated.  Might come in handy for this.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
