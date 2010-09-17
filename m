Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6A4FC6B007B
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 13:54:35 -0400 (EDT)
Date: Fri, 17 Sep 2010 13:54:19 -0400
From: William Thompson <wt@electro-mechanical.com>
Subject: Re: OOM help
Message-ID: <20100917175419.GA9873@electro-mechanical.com>
References: <20100915120349.GH29041@electro-mechanical.com> <20100916164231.3BC3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100916164231.3BC3.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 17, 2010 at 09:39:11AM +0900, KOSAKI Motohiro wrote:
> Hi William

As before, please keep me in CC.  I am not on the kernel list nor the mm
list.

> > Here is the dmesg when the oom kicked in:
> > [1557576.330762] Xorg invoked oom-killer: gfp_mask=0xd0, order=0, oomkilladj=0
> 
> GFP_KERNEL.

Can you tell me what that means?

> > [1557576.330767] Pid: 6696, comm: Xorg Not tainted 2.6.31.3 #1
> > [1557576.330769] Call Trace:
> > [1557576.330775]  [<c02679ec>] ? oom_kill_process+0xac/0x250
> > [1557576.330777]  [<c0267e57>] ? badness+0x167/0x240
> > [1557576.330780]  [<c0268074>] ? __out_of_memory+0x144/0x170
> > [1557576.330782]  [<c02680f4>] ? out_of_memory+0x54/0xb0
> > [1557576.330785]  [<c026b211>] ? __alloc_pages_nodemask+0x541/0x560
> > [1557576.330788]  [<c026b284>] ? __get_free_pages+0x14/0x30
> > [1557576.330791]  [<c02a1b62>] ? __pollwait+0xa2/0xf0
> > [1557576.330794]  [<c0479ab4>] ? unix_poll+0x14/0xa0
> > [1557576.330797]  [<c040a00c>] ? sock_poll+0xc/0x10
> > [1557576.330799]  [<c02a12ab>] ? do_select+0x2bb/0x550
> > [1557576.330801]  [<c02a1ac0>] ? __pollwait+0x0/0xf0
> > [1557576.330804]  [<c02a1bb0>] ? pollwake+0x0/0x80
> > [1557576.330806]  [<c02a1bb0>] ? pollwake+0x0/0x80
> > [1557576.330808]  [<c02a1bb0>] ? pollwake+0x0/0x80
> > [1557576.330810]  [<c02a1bb0>] ? pollwake+0x0/0x80
> > [1557576.330812]  [<c02a1bb0>] ? pollwake+0x0/0x80
> > [1557576.330814]  [<c02a1bb0>] ? pollwake+0x0/0x80
> > [1557576.330816]  [<c02a1bb0>] ? pollwake+0x0/0x80
> > [1557576.330818]  [<c02a1bb0>] ? pollwake+0x0/0x80
> > [1557576.330821]  [<c02a1bb0>] ? pollwake+0x0/0x80
> > [1557576.330823]  [<c02a1bb0>] ? pollwake+0x0/0x80
> > [1557576.330825]  [<c02a1bb0>] ? pollwake+0x0/0x80
> > [1557576.330827]  [<c02a1bb0>] ? pollwake+0x0/0x80
> > [1557576.330829]  [<c02a1bb0>] ? pollwake+0x0/0x80
> > [1557576.330831]  [<c02a1bb0>] ? pollwake+0x0/0x80
> > [1557576.330833]  [<c02a1bb0>] ? pollwake+0x0/0x80
> > [1557576.330835]  [<c02a1bb0>] ? pollwake+0x0/0x80
> > [1557576.330837]  [<c02a1bb0>] ? pollwake+0x0/0x80
> > [1557576.330839]  [<c02a1bb0>] ? pollwake+0x0/0x80
> > [1557576.330841]  [<c02a1730>] ? core_sys_select+0x1f0/0x320
> > [1557576.330844]  [<c029f9f3>] ? do_vfs_ioctl+0x3e3/0x610
> > [1557576.330847]  [<c024354c>] ? hrtimer_try_to_cancel+0x3c/0x80
> > [1557576.330850]  [<c02481a4>] ? getnstimeofday+0x54/0x110
> > [1557576.330852]  [<c02a1a3f>] ? sys_select+0x2f/0xb0
> > [1557576.330855]  [<c0202f61>] ? syscall_call+0x7/0xb
> > [1557576.330857] Mem-Info:
> > [1557576.330858] DMA per-cpu:
> > [1557576.330860] CPU    0: hi:    0, btch:   1 usd:   0
> > [1557576.330861] CPU    1: hi:    0, btch:   1 usd:   0
> > [1557576.330863] CPU    2: hi:    0, btch:   1 usd:   0
> > [1557576.330864] CPU    3: hi:    0, btch:   1 usd:   0
> > [1557576.330865] Normal per-cpu:
> > [1557576.330867] CPU    0: hi:  186, btch:  31 usd: 104
> > [1557576.330868] CPU    1: hi:  186, btch:  31 usd: 167
> > [1557576.330870] CPU    2: hi:  186, btch:  31 usd: 171
> > [1557576.330871] CPU    3: hi:  186, btch:  31 usd: 173
> > [1557576.330873] HighMem per-cpu:
> > [1557576.330874] CPU    0: hi:  186, btch:  31 usd:  24
> > [1557576.330875] CPU    1: hi:  186, btch:  31 usd:   1
> > [1557576.330877] CPU    2: hi:  186, btch:  31 usd:  23
> > [1557576.330878] CPU    3: hi:  186, btch:  31 usd:  17
> > [1557576.330881] Active_anon:99096 active_file:75187 inactive_anon:14426
> > [1557576.330882]  inactive_file:1117251 unevictable:867 dirty:0 writeback:256 unstable:0
> > [1557576.330883]  free:673090 slab:89233 mapped:22358 pagetables:1487 bounce:0
> > [1557576.330886] DMA free:1984kB min:88kB low:108kB high:132kB active_anon:0kB inactive_anon:0kB active_file:140kB inactive_file:0kB unevictable:0kB present:15864kB pages_scanned:256 all_unreclaimable? yes
> > [1557576.330888] lowmem_reserve[]: 0 478 8104 8104
> > [1557576.330892] Normal free:2728kB min:2752kB low:3440kB high:4128kB 
>                    active_anon:0kB inactive_anon:0kB active_file:23296kB inactive_file:22748kB unevictable:0kB
>                    present:489704kB pages_scanned:72700 all_unreclaimable? yes
> 
> present: 500MB
> file cache: 50MB
> all_unreclaimable: yes
> 
> That said, there are two possibility.
>  1) your kernel (probably drivers) have memory leak
>  2) you are using really lots of GFP_KERNEL memory. and then, you need to switch 64bit kernel

1) The only kernel side thing that changed during the original 300 days was
an upgrade to virtualbox (I'm using 3.2.6 OSE from Debian)  Although the
modules were loaded, the log that I gave was without starting virtualbox GUI
or any VMs.

I'd also like to mention that the initial OOM of every single problem was
always Xorg.  Unfortunately, I did not have any monitoring running when it
occured.

2) I'm not sure why all the memory issues I have are related to that one
raid1 set (sd[cd]).  I did have a 64-bit kernel on here at one time,
however, being that my userland is still all 32-bit (and not easily
changed), I had some odd problems with it.  Plus virtualbox doesn't work
with 64-bit kernel and 32-bit userland.  On a side note, I noticed that the
reported memory was about 200mb smaller with 64-bit kernel.

> Can you please try latest kernel and try reproduce? I'm curios two point.
> 1) If latest doesn't OOM, the leak has been fixed already.
> 2) If the OOM occur, latest output more detailed information.

I did try a 2.6.33.8 kernel when all this occured, but it appeared that it
wanted to crash quicker.  I know that 33.8 isn't that new.  I had some
problems with 34.x on another system and didn't want to go higher at that
time.  (Sorry, I forgot now what the problems were)

Thanks for your explanation that you already gave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
