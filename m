Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 96B586B0044
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 18:53:49 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so2006169dad.14
        for <linux-mm@kvack.org>; Fri, 02 Nov 2012 15:53:48 -0700 (PDT)
Date: Sat, 3 Nov 2012 07:53:41 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: zram on ARM
Message-ID: <20121102225341.GC2070@barrios>
References: <CAA25o9SD8cZUaVT-SA2f9NVvPdmYo++WGn8Gfie3bhkrc8dCxQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA25o9SD8cZUaVT-SA2f9NVvPdmYo++WGn8Gfie3bhkrc8dCxQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>

Hi Luigi,

I am embarrassed because recently I have tried to promote zram
from staging tree.

I thought it's very stable because our production team already have
used recent zram on ARM and they don't report any problem to me until now.
But I'm not sure how they use it stressfully so I will check it.
And other many project of android have used it but I doubt it's recent zram
so it would be a problem of recent patch.

Anyway I will look at it but unfortunately, as I said earlier, I should go
to training course during 2 weeks. So reply will be late.
I hope other people involve in during that.

Thanks for the reporting.

On Fri, Nov 02, 2012 at 12:59:13PM -0700, Luigi Semenzato wrote:
> Does anybody have any information on the status of zram on ARM?
> Specifically, how much it has been tested.
> 
> I noticed that zram and zsmalloc on ToT no longer have the x86
> restriction, and they compile fine on our 3.4 branch.  Sadly, that's
> where my luck ends.
> 
> When I run my standard Chrome load (which just opens a bunch of
> memory-intensive browser tabs), Chrome dies shortly after the system
> starts swapping pages out.  For instance, here's are the SI and SO
> fields of "vmstat 1":
> 
>    si   so
>     0    0
>     0    0
>     0    0
>     0    0
>     0    0
>     0    0
>     0    0
>     0    0
>     0  168
>     0    0
>     0  924
>   188 26332
>   520 30672
>  1304 32208
>  2360 30804
>  18836 24832
>                      <--- chrome dies here
>  6496    0
>   892    0
>   260    0
>     8    0
> 
> I also have a simpler load: a program that allocates memory non-stop,
> and fills part of it with data from /dev/urandom (to simulate the
> observed compressibility). The program never reads its data though, so
> it doesn't get swapped back in, as in the previous load.  This runs
> for a while and partially fills the swap device, then the system
> hangs.
> 
> Deja vu, eh?  I am running this with my patch, which may result in
> extra OOM kills.  Interestingly, a few threads are blocked in
> exit_mm(), but not on a page fault.  Most processes are in
> congestion_wait(), so this is probably not the same situation I was
> seeing earlier.
> 
> Anyway, I am attaching the output of SysRQ-X with lots of stack
> traces.  Thank you very much for any information!
> 
> Luigi



-- 
Kind Regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
