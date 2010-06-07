Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 540376B0071
	for <linux-mm@kvack.org>; Mon,  7 Jun 2010 06:00:15 -0400 (EDT)
Received: by vws8 with SMTP id 8so322613vws.14
        for <linux-mm@kvack.org>; Mon, 07 Jun 2010 03:00:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1275902395.7258.9.camel@toshiba-laptop>
References: <AANLkTikXdy6GOQ2EzDt-yrcJ_jMIPvLsH3neWBozpVCK@mail.gmail.com>
	<1275902395.7258.9.camel@toshiba-laptop>
Date: Mon, 7 Jun 2010 18:00:10 +0800
Message-ID: <AANLkTin1OS3LohKBvWyS81BoAk15Y-riCiEdcevSA7ye@mail.gmail.com>
Subject: Re: mmotm 2010-06-03-16-36 lots of suspected kmemleak
From: Dave Young <hidave.darkstar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 7, 2010 at 5:19 PM, Catalin Marinas <catalin.marinas@arm.com> wrote:
> On Mon, 2010-06-07 at 06:20 +0100, Dave Young wrote:
>> On Fri, Jun 4, 2010 at 9:55 PM, Dave Young <hidave.darkstar@gmail.com> wrote:
>> > On Fri, Jun 4, 2010 at 6:50 PM, Catalin Marinas <catalin.marinas@arm.com> wrote:
>> >> Dave Young <hidave.darkstar@gmail.com> wrote:
>> >>> With mmotm 2010-06-03-16-36, I gots tuns of kmemleaks
>> >>
>> >> Do you have CONFIG_NO_BOOTMEM enabled? I posted a patch for this but
>> >> hasn't been reviewed yet (I'll probably need to repost, so if it fixes
>> >> the problem for you a Tested-by would be nice):
>> >>
>> >> http://lkml.org/lkml/2010/5/4/175
>> >
>> >
>> > I'd like to test, but I can not access the test pc during weekend. So
>> > I will test it next monday.
>>
>> Bad news, the patch does not fix this issue.
>
> Thanks for trying. Could you please just disable CONFIG_NO_BOOTMEM and
> post the kmemleak reported leaks again?
>

Still too many suspected leaks, results similar with
(CONFIG_NO_BOOTMEM = y && apply your patch), looks like a little
different from original ones? I just copy some of them here:

unreferenced object 0xde3c7420 (size 44):
  comm "bash", pid 1631, jiffies 4294897023 (age 223.573s)
  hex dump (first 32 bytes):
    05 05 00 00 ad 4e ad de ff ff ff ff ff ff ff ff  .....N..........
    98 42 d9 c1 00 00 00 00 50 fe 63 c1 10 32 8f dd  .B......P.c..2..
  backtrace:
    [<c1498ad2>] kmemleak_alloc+0x4a/0x83
    [<c10c1ace>] kmem_cache_alloc+0xde/0x12a
    [<c10b421b>] anon_vma_fork+0x31/0x88
    [<c102c71d>] dup_mm+0x1d3/0x38f
    [<c102d20d>] copy_process+0x8ce/0xf39
    [<c102d990>] do_fork+0x118/0x295
    [<c1007fe0>] sys_clone+0x1f/0x24
    [<c10029b1>] ptregs_clone+0x15/0x24
    [<ffffffff>] 0xffffffff
unreferenced object 0xde3c73f0 (size 44):
  comm "bash", pid 1631, jiffies 4294897023 (age 223.573s)
  hex dump (first 32 bytes):
    02 02 00 00 ad 4e ad de ff ff ff ff ff ff ff ff  .....N..........
    98 42 d9 c1 00 00 00 00 50 fe 63 c1 10 32 8f dd  .B......P.c..2..
  backtrace:
    [<c1498ad2>] kmemleak_alloc+0x4a/0x83
    [<c10c1ace>] kmem_cache_alloc+0xde/0x12a
    [<c10b421b>] anon_vma_fork+0x31/0x88
    [<c102c71d>] dup_mm+0x1d3/0x38f
    [<c102d20d>] copy_process+0x8ce/0xf39
    [<c102d990>] do_fork+0x118/0x295
    [<c1007fe0>] sys_clone+0x1f/0x24
    [<c10029b1>] ptregs_clone+0x15/0x24
    [<ffffffff>] 0xffffffff
unreferenced object 0xde3c73c0 (size 44):
  comm "bash", pid 1631, jiffies 4294897023 (age 223.573s)
  hex dump (first 32 bytes):
    02 02 00 00 ad 4e ad de ff ff ff ff ff ff ff ff  .....N..........
    98 42 d9 c1 00 00 00 00 50 fe 63 c1 e0 31 8f dd  .B......P.c..1..
  backtrace:
    [<c1498ad2>] kmemleak_alloc+0x4a/0x83
    [<c10c1ace>] kmem_cache_alloc+0xde/0x12a
    [<c10b421b>] anon_vma_fork+0x31/0x88
    [<c102c71d>] dup_mm+0x1d3/0x38f
    [<c102d20d>] copy_process+0x8ce/0xf39
    [<c102d990>] do_fork+0x118/0x295
    [<c1007fe0>] sys_clone+0x1f/0x24
    [<c10029b1>] ptregs_clone+0x15/0x24
    [<ffffffff>] 0xffffffff
unreferenced object 0xde3c7570 (size 44):
  comm "bash", pid 1631, jiffies 4294897023 (age 223.573s)
  hex dump (first 32 bytes):
    02 02 00 00 ad 4e ad de ff ff ff ff ff ff ff ff  .....N..........
    98 42 d9 c1 00 00 00 00 50 fe 63 c1 e0 31 8f dd  .B......P.c..1..
  backtrace:
    [<c1498ad2>] kmemleak_alloc+0x4a/0x83
    [<c10c1ace>] kmem_cache_alloc+0xde/0x12a
    [<c10b421b>] anon_vma_fork+0x31/0x88
    [<c102c71d>] dup_mm+0x1d3/0x38f
    [<c102d20d>] copy_process+0x8ce/0xf39
    [<c102d990>] do_fork+0x118/0x295
    [<c1007fe0>] sys_clone+0x1f/0x24
    [<c10029b1>] ptregs_clone+0x15/0x24
    [<ffffffff>] 0xffffffff
unreferenced object 0xde3c7390 (size 44):
  comm "bash", pid 1631, jiffies 4294897023 (age 223.573s)
  hex dump (first 32 bytes):
    05 05 00 00 ad 4e ad de ff ff ff ff ff ff ff ff  .....N..........
    98 42 d9 c1 00 00 00 00 50 fe 63 c1 b0 31 8f dd  .B......P.c..1..
  backtrace:
    [<c1498ad2>] kmemleak_alloc+0x4a/0x83
    [<c10c1ace>] kmem_cache_alloc+0xde/0x12a
    [<c10b421b>] anon_vma_fork+0x31/0x88
    [<c102c71d>] dup_mm+0x1d3/0x38f
    [<c102d20d>] copy_process+0x8ce/0xf39
    [<c102d990>] do_fork+0x118/0x295
    [<c1007fe0>] sys_clone+0x1f/0x24
    [<c10029b1>] ptregs_clone+0x15/0x24
    [<ffffffff>] 0xffffffff
unreferenced object 0xde3c7540 (size 44):
  comm "bash", pid 1631, jiffies 4294897023 (age 223.576s)
  hex dump (first 32 bytes):
    02 02 00 00 ad 4e ad de ff ff ff ff ff ff ff ff  .....N..........
    98 42 d9 c1 00 00 00 00 50 fe 63 c1 b0 31 8f dd  .B......P.c..1..
  backtrace:
    [<c1498ad2>] kmemleak_alloc+0x4a/0x83
    [<c10c1ace>] kmem_cache_alloc+0xde/0x12a
    [<c10b421b>] anon_vma_fork+0x31/0x88
    [<c102c71d>] dup_mm+0x1d3/0x38f
    [<c102d20d>] copy_process+0x8ce/0xf39
    [<c102d990>] do_fork+0x118/0x295
    [<c1007fe0>] sys_clone+0x1f/0x24
    [<c10029b1>] ptregs_clone+0x15/0x24
    [<ffffffff>] 0xffffffff
unreferenced object 0xde3c7360 (size 44):
  comm "bash", pid 1631, jiffies 4294897023 (age 223.576s)
  hex dump (first 32 bytes):
    05 05 00 00 ad 4e ad de ff ff ff ff ff ff ff ff  .....N..........
    98 42 d9 c1 00 00 00 00 50 fe 63 c1 40 32 8f dd  .B......P.c.@2..
  backtrace:
    [<c1498ad2>] kmemleak_alloc+0x4a/0x83
    [<c10c1ace>] kmem_cache_alloc+0xde/0x12a
    [<c10b421b>] anon_vma_fork+0x31/0x88
    [<c102c71d>] dup_mm+0x1d3/0x38f
    [<c102d20d>] copy_process+0x8ce/0xf39
    [<c102d990>] do_fork+0x118/0x295
    [<c1007fe0>] sys_clone+0x1f/0x24
    [<c10029b1>] ptregs_clone+0x15/0x24
    [<ffffffff>] 0xffffffff
unreferenced object 0xde3c7330 (size 44):
  comm "bash", pid 1631, jiffies 4294897023 (age 223.576s)
  hex dump (first 32 bytes):
    02 02 00 00 ad 4e ad de ff ff ff ff ff ff ff ff  .....N..........
    98 42 d9 c1 00 00 00 00 50 fe 63 c1 40 32 8f dd  .B......P.c.@2..
  backtrace:
    [<c1498ad2>] kmemleak_alloc+0x4a/0x83
    [<c10c1ace>] kmem_cache_alloc+0xde/0x12a
    [<c10b421b>] anon_vma_fork+0x31/0x88
    [<c102c71d>] dup_mm+0x1d3/0x38f
    [<c102d20d>] copy_process+0x8ce/0xf39
    [<c102d990>] do_fork+0x118/0x295
    [<c1007fe0>] sys_clone+0x1f/0x24
    [<c10029b1>] ptregs_clone+0x15/0x24
    [<ffffffff>] 0xffffffff
unreferenced object 0xde3c7510 (size 44):
  comm "bash", pid 1631, jiffies 4294897023 (age 223.576s)
  hex dump (first 32 bytes):
    03 03 00 00 ad 4e ad de ff ff ff ff ff ff ff ff  .....N..........
    98 42 d9 c1 00 00 00 00 50 fe 63 c1 90 30 8f dd  .B......P.c..0..
  backtrace:
    [<c1498ad2>] kmemleak_alloc+0x4a/0x83
    [<c10c1ace>] kmem_cache_alloc+0xde/0x12a
    [<c10b421b>] anon_vma_fork+0x31/0x88
    [<c102c71d>] dup_mm+0x1d3/0x38f
    [<c102d20d>] copy_process+0x8ce/0xf39
    [<c102d990>] do_fork+0x118/0x295
    [<c1007fe0>] sys_clone+0x1f/0x24
    [<c10029b1>] ptregs_clone+0x15/0x24
    [<ffffffff>] 0xffffffff
unreferenced object 0xde3c75a0 (size 44):
  comm "bash", pid 1631, jiffies 4294897023 (age 223.576s)
  hex dump (first 32 bytes):
    02 02 00 00 ad 4e ad de ff ff ff ff ff ff ff ff  .....N..........
    98 42 d9 c1 00 00 00 00 50 fe 63 c1 60 30 8f dd  .B......P.c.`0..
  backtrace:
    [<c1498ad2>] kmemleak_alloc+0x4a/0x83
    [<c10c1ace>] kmem_cache_alloc+0xde/0x12a
    [<c10b421b>] anon_vma_fork+0x31/0x88
    [<c102c71d>] dup_mm+0x1d3/0x38f
    [<c102d20d>] copy_process+0x8ce/0xf39
    [<c102d990>] do_fork+0x118/0x295
    [<c1007fe0>] sys_clone+0x1f/0x24
    [<c10029b1>] ptregs_clone+0x15/0x24
    [<ffffffff>] 0xffffffff
unreferenced object 0xde3c74b0 (size 44):
  comm "bash", pid 1631, jiffies 4294897023 (age 223.576s)
  hex dump (first 32 bytes):
    02 02 00 00 ad 4e ad de ff ff ff ff ff ff ff ff  .....N..........
    98 42 d9 c1 00 00 00 00 50 fe 63 c1 60 30 8f dd  .B......P.c.`0..
  backtrace:
    [<c1498ad2>] kmemleak_alloc+0x4a/0x83
    [<c10c1ace>] kmem_cache_alloc+0xde/0x12a
    [<c10b421b>] anon_vma_fork+0x31/0x88
    [<c102c71d>] dup_mm+0x1d3/0x38f
    [<c102d20d>] copy_process+0x8ce/0xf39
    [<c102d990>] do_fork+0x118/0x295
    [<c1007fe0>] sys_clone+0x1f/0x24
    [<c10029b1>] ptregs_clone+0x15/0x24
    [<ffffffff>] 0xffffffff
unreferenced object 0xde3c7b70 (size 44):
  comm "ps", pid 1666, jiffies 4294897029 (age 223.560s)
  hex dump (first 32 bytes):
    04 04 00 00 ad 4e ad de ff ff ff ff ff ff ff ff  .....N..........
    98 42 d9 c1 00 00 00 00 50 fe 63 c1 70 7b 3c de  .B......P.c.p{<.
  backtrace:
    [<c1498ad2>] kmemleak_alloc+0x4a/0x83
    [<c10c1ace>] kmem_cache_alloc+0xde/0x12a
    [<c10b42e4>] anon_vma_prepare+0x72/0x12e
    [<c10ad3e5>] handle_mm_fault+0x153/0x60d
    [<c14b5d3e>] do_page_fault+0x2ee/0x304
    [<c14b3a47>] error_code+0x6b/0x70
    [<ffffffff>] 0xffffffff
unreferenced object 0xde3c7b40 (size 44):
  comm "ps", pid 1666, jiffies 4294897029 (age 223.560s)
  hex dump (first 32 bytes):
    04 04 00 00 ad 4e ad de ff ff ff ff ff ff ff ff  .....N..........
    98 42 d9 c1 00 00 00 00 50 fe 63 c1 40 7b 3c de  .B......P.c.@{<.
  backtrace:
    [<c1498ad2>] kmemleak_alloc+0x4a/0x83
    [<c10c1ace>] kmem_cache_alloc+0xde/0x12a
    [<c10b42e4>] anon_vma_prepare+0x72/0x12e
    [<c10ad3e5>] handle_mm_fault+0x153/0x60d
    [<c14b5d3e>] do_page_fault+0x2ee/0x304
    [<c14b3a47>] error_code+0x6b/0x70
    [<c109b3ff>] generic_file_aio_read+0x398/0x5ce
    [<c10c85e5>] do_sync_read+0x8c/0xca
    [<c10c8fa3>] vfs_read+0x81/0xdb
    [<c10c9096>] sys_read+0x3b/0x60
    [<c14b340d>] syscall_call+0x7/0xb
    [<ffffffff>] 0xffffffff

> Thanks.
>
> --
> Catalin
>
>



-- 
Regards
dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
