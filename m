Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 079A76B0071
	for <linux-mm@kvack.org>; Mon,  7 Jun 2010 12:43:25 -0400 (EDT)
Subject: Re: mmotm 2010-06-03-16-36 lots of suspected kmemleak
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <AANLkTin1OS3LohKBvWyS81BoAk15Y-riCiEdcevSA7ye@mail.gmail.com>
References: <AANLkTin1OS3LohKBvWyS81BoAk15Y-riCiEdcevSA7ye@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 07 Jun 2010 17:43:20 +0100
Message-ID: <1275929000.3021.56.camel@e102109-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Young <hidave.darkstar@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2010-06-07 at 11:00 +0100, Dave Young wrote:
> On Mon, Jun 7, 2010 at 5:19 PM, Catalin Marinas <catalin.marinas@arm.com> wrote:
> > On Mon, 2010-06-07 at 06:20 +0100, Dave Young wrote:
> >> On Fri, Jun 4, 2010 at 9:55 PM, Dave Young <hidave.darkstar@gmail.com> wrote:
> >> > On Fri, Jun 4, 2010 at 6:50 PM, Catalin Marinas <catalin.marinas@arm.com> wrote:
> >> >> Dave Young <hidave.darkstar@gmail.com> wrote:
> >> >>> With mmotm 2010-06-03-16-36, I gots tuns of kmemleaks
> >> >>
> >> >> Do you have CONFIG_NO_BOOTMEM enabled? I posted a patch for this but
> >> >> hasn't been reviewed yet (I'll probably need to repost, so if it fixes
> >> >> the problem for you a Tested-by would be nice):
> >> >>
> >> >> http://lkml.org/lkml/2010/5/4/175
> >> >
> >> >
> >> > I'd like to test, but I can not access the test pc during weekend. So
> >> > I will test it next monday.
> >>
> >> Bad news, the patch does not fix this issue.
> >
> > Thanks for trying. Could you please just disable CONFIG_NO_BOOTMEM and
> > post the kmemleak reported leaks again?
> 
> Still too many suspected leaks, results similar with
> (CONFIG_NO_BOOTMEM = y && apply your patch), looks like a little
> different from original ones? I just copy some of them here:
> 
> unreferenced object 0xde3c7420 (size 44):
>   comm "bash", pid 1631, jiffies 4294897023 (age 223.573s)
>   hex dump (first 32 bytes):
>     05 05 00 00 ad 4e ad de ff ff ff ff ff ff ff ff  .....N..........
>     98 42 d9 c1 00 00 00 00 50 fe 63 c1 10 32 8f dd  .B......P.c..2..
>   backtrace:
>     [<c1498ad2>] kmemleak_alloc+0x4a/0x83
>     [<c10c1ace>] kmem_cache_alloc+0xde/0x12a
>     [<c10b421b>] anon_vma_fork+0x31/0x88
>     [<c102c71d>] dup_mm+0x1d3/0x38f
>     [<c102d20d>] copy_process+0x8ce/0xf39
>     [<c102d990>] do_fork+0x118/0x295
>     [<c1007fe0>] sys_clone+0x1f/0x24
>     [<c10029b1>] ptregs_clone+0x15/0x24
>     [<ffffffff>] 0xffffffff

I'll try to test the mmotm kernel as well. I don't get any kmemleak
reports with the 2.6.35-rc1 kernel.

Can you send me your .config file? Do you have CONFIG_HUGETLBFS enabled?

Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
