Message-ID: <008901c55abb$cec81350$0f01a8c0@max>
From: "Richard Purdie" <rpurdie@rpsys.net>
References: <20050516130048.6f6947c1.akpm@osdl.org><20050516210655.E634@flint.arm.linux.org.uk><030401c55a6e$34e67cb0$0f01a8c0@max><20050516163900.6daedc40.akpm@osdl.org> <17033.14096.441537.200132@gargle.gargle.HOWL>
Subject: Re: 2.6.12-rc4-mm2
Date: Tue, 17 May 2005 09:38:26 +0100
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Wolfgang Wander <wwc@rentec.com>, Andrew Morton <akpm@osdl.org>
Cc: rmk@arm.linux.org.uk, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Wolfgang Wander:
> > > Its a bit late for me to try and debug this further and I'm not sure I 
> > > know
> > > the mm layer well enough to do so anyway. With these patches 
> > > removed, -mm1
> > > boots fine. I'm confident the same will apply to -mm2.
> >
> > Great, thanks.
> >
> > Wolfgang, we broke ARM.
>
> Thanks Richard for the debugging.
>
> Can you try the following patch that fixes a stupid typo of mine:

I applied this against -mm2 and can comfirm it fixes the problem.

Thanks,

Richard


> Signed-off-by: Wolfgang Wander <wwc@rentec.com>
>
> --- linux-2.6.12-rc4-wwc/arch/arm/mm/mmap.c~    2005-05-10 
> 16:33:34.000000000 -0400
> +++ linux-2.6.12-rc4-wwc/arch/arm/mm/mmap.c     2005-05-16 
> 20:10:05.000000000 -0400
> @@ -76,7 +76,7 @@ arch_get_unmapped_area(struct file *filp
>        if( len > mm->cached_hole_size )
>                start_addr = addr = mm->free_area_cache;
>        else {
> -               start_addr = TASK_UNMAPPED_BASE;
> +               start_addr = addr = TASK_UNMAPPED_BASE;
>                mm->cached_hole_size = 0;
>        }
>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
