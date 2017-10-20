Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 161676B0038
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 20:33:51 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y128so3205526pfg.5
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 17:33:51 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id x5si10354474plo.143.2017.10.19.17.33.48
        for <linux-mm@kvack.org>;
        Thu, 19 Oct 2017 17:33:48 -0700 (PDT)
Date: Fri, 20 Oct 2017 09:33:46 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: swap_info_get: Bad swap offset entry 0200f8a7
Message-ID: <20171020003346.GA855@bbox>
References: <alpine.DEB.2.21.1.1710151642580.2375@trent.utfs.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1.1710151642580.2375@trent.utfs.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Kujau <lists@nerdbynature.de>
Cc: linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Nitin Gupta <ngupta@vflare.org>, Robert Schelander <rschelander@aon.at>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "Huang, Ying" <ying.huang@intel.com>

Hello,

On Sun, Oct 15, 2017 at 05:17:36PM -0700, Christian Kujau wrote:
> Hi,
> 
> every now and then (and more frequently now) I receive the following 
> message on this Atom N270 netbook:
> 
>   swap_info_get: Bad swap offset entry 0200f8a7
> 
> This started to show up a few months ago but appears to happen more 
> frequently now:
> 
>       4 May  < Linux version 4.11.2-1-ARCH
>       4 Jun  < Linux version 4.11.3-1-ARCH
>       7 Jul  < Linux version 4.11.9-1-ARCH
>       4 Aug  < Linux version 4.12.8-2-ARCH
>      24 Sep  < Linux version 4.12.13-1-ARCH
>     158 Oct  < Linux version 4.13.5-1-ARCH
> 
> I've only found (very) old reports for this[0][2] with either no 
> solution[1] or some hinting that this may be caused by hardware errors.

Since 4.11, there are lots of happenings in swap subsystem to be optimized
so it might be related to one of those changes but I'm not sure.
Worth to Ccing Huang who may know somethings since then.

Thanks.

> 
> In my case howerver no kernel BUG messages or oopses are involved and no
> PTE errors are logged. The machine appears to be very stable, although
> memory usage is quite high on that machine (but no OOM situations so
> far either). As the machine is only equipped with 1GB of RAM, I'm
> using ZRAM on this system, which usually looks something like this:
> 
>   $ zramctl 
>   NAME       ALGORITHM DISKSIZE   DATA COMPR TOTAL STREAMS MOUNTPOINT
>   /dev/zram0 lz4         248.7M 195.7M   74M 78.7M       2 [SWAP]
> 
> I suspect that, when memory pressure is high, zram may not be quick enough 
> to decompress a page leading to these messages, but then I'd have expected 
> a zram error message too.
> 
> Can anybody comment on these messages? If they're really indicating a 
> hardware error, shouldn't there be other messages too? So far, rasdaemon 
> has not logged any errors.
> 
> Thanks,
> Christian.
> 
> [0] http://lkml.iu.edu/hypermail/linux/kernel/0204.3/0165.html
> [1] https://bugzilla.redhat.com/show_bug.cgi?id=432337
> [2] https://access.redhat.com/solutions/218733
> -- 
> BOFH excuse #323:
> 
> Your processor has processed too many instructions.  Turn it off immediately, do not type any commands!!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
