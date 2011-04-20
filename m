Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C04A08D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 00:47:26 -0400 (EDT)
Received: by iwg8 with SMTP id 8so463242iwg.14
        for <linux-mm@kvack.org>; Tue, 19 Apr 2011 21:47:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTinOV=tXcC-XipPzUhs-yODjnOu=8g@mail.gmail.com>
References: <BANLkTinOV=tXcC-XipPzUhs-yODjnOu=8g@mail.gmail.com>
Date: Wed, 20 Apr 2011 13:47:23 +0900
Message-ID: <BANLkTik_wKoJ43XBPWd4tb9hMds-_7aVCg@mail.gmail.com>
Subject: Re: [HELP] OOM:Page allocation fragment issue
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: TAO HU <tghk48@motorola.com>
Cc: linux-mm@kvack.org, linux-input@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>

On Wed, Apr 20, 2011 at 11:59 AM, TAO HU <tghk48@motorola.com> wrote:
> Hi, All
>
> I got a issue that kmalloc() fails to allocate 32-K page while there
> are still pretty much total memory available (60+MB).
> Any suggestions? Any thing I can tune to reduced the failure cases?
>
> It happens with 2.6.35 kernel
>
> <4>[ 6232.631622] getevent invoked oom-killer: gfp_mask=3D0xd0, order=3D3=
, oom_adj=3D0
> <4>[ 6232.639312] [<c0053230>] (unwind_backtrace+0x0/0xf0) from
> [<c0109a88>] (dump_header.clone.1+0x50/0x84)
> <4>[ 6232.649597] [<c0109a88>] (dump_header.clone.1+0x50/0x84) from
> [<c0109af0>] (oom_kill_process.clone.0+0x34/0xec)
> <4>[ 6232.660705] [<c0109af0>] (oom_kill_process.clone.0+0x34/0xec)
> from [<c0109d04>] (__out_of_memory+0x15c/0x184)
> <4>[ 6232.671630] [<c0109d04>] (__out_of_memory+0x15c/0x184) from
> [<c0109dc0>] (out_of_memory+0x94/0xd4)
> <4>[ 6232.681488] [<c0109dc0>] (out_of_memory+0x94/0xd4) from
> [<c010d474>] (__alloc_pages_nodemask+0x4c4/0x6e8)
> <4>[ 6232.692016] [<c010d474>] (__alloc_pages_nodemask+0x4c4/0x6e8)
> from [<c0131fec>] (cache_grow.clone.0+0xac/0x3e4)
> <4>[ 6232.703125] [<c0131fec>] (cache_grow.clone.0+0xac/0x3e4) from
> [<c013334c>] (__kmalloc+0x3ec/0x6c4)
> <4>[ 6232.712982] [<c013334c>] (__kmalloc+0x3ec/0x6c4) from
> [<c0393f9c>] (evdev_open+0x94/0x1ec)
> <4>[ 6232.722137] [<c0393f9c>] (evdev_open+0x94/0x1ec) from
> [<c0390cac>] (input_open_file+0x184/0x2d8)
> <4>[ 6232.731781] [<c0390cac>] (input_open_file+0x184/0x2d8) from
> [<c013b668>] (chrdev_open+0x20c/0x234)
> <4>[ 6232.741638] [<c013b668>] (chrdev_open+0x20c/0x234) from
> [<c0136b80>] (__dentry_open+0x200/0x324)
> <4>[ 6232.751281] [<c0136b80>] (__dentry_open+0x200/0x324) from
> [<c0136d60>] (nameidata_to_filp+0x3c/0x50)
> <4>[ 6232.761322] [<c0136d60>] (nameidata_to_filp+0x3c/0x50) from
> [<c0142878>] (do_last+0x4c8/0x5ec)
> <4>[ 6232.770782] [<c0142878>] (do_last+0x4c8/0x5ec) from [<c0144450>]
> (do_filp_open+0x184/0x514)
> <4>[ 6232.779937] [<c0144450>] (do_filp_open+0x184/0x514) from
> [<c0136824>] (do_sys_open+0x58/0x18c)
> <4>[ 6232.789428] [<c0136824>] (do_sys_open+0x58/0x18c) from
> [<c004db20>] (ret_fast_syscall+0x0/0x30)
> <4>[ 6232.798980] Mem-info:
> <4>[ 6232.801483] Normal per-cpu:
> <4>[ 6232.804565] CPU =C2=A0 =C2=A00: hi: =C2=A0186, btch: =C2=A031 usd: =
=C2=A015
> <4>[ 6232.809844] active_anon:34424 inactive_anon:36745 isolated_anon:3
> <4>[ 6232.809875] =C2=A0active_file:2 inactive_file:0 isolated_file:65
> <4>[ 6232.809875] =C2=A0unevictable:95 dirty:0 writeback:0 unstable:0
> <4>[ 6232.809906] =C2=A0free:16133 slab_reclaimable:1274 slab_unreclaimab=
le:3892
> <4>[ 6232.809906] =C2=A0mapped:8809 shmem:263 pagetables:4657 bounce:0
> <4>[ 6232.841766] Normal free:64532kB min:2884kB low:3604kB
> high:4324kB active_anon:137696kB inactive_anon:146980kB
> active_file:8kB inactive_file:0kB unevictable:380kB

There are lots of anon pages but few file pages.

> isolated(anon):12kB isolated(file):260kB present:520192kB mlocked:0kB
> dirty:0kB writeback:0kB mapped:35236kB shmem:1052kB
> slab_reclaimable:5096kB slab_unreclaimable:15568kB kernel_stack:6544kB
> pagetables:18628kB unstable:0kB bounce:0kB writeback_tmp:0kB
> pages_scanned:34 all_unreclaimable? no
> <4>[ 6232.885314] lowmem_reserve[]: 0 0 0
> <4>[ 6232.889190] Normal: 10659*4kB 2735*8kB 1*16kB 0*32kB 0*64kB
> 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 64532kB

There isn't any pages of bigger 32K in your system.
Memory fragmentation is high.

> <4>[ 6232.901367] 397 total pagecache pages
> <4>[ 6232.905395] 0 pages in swap cache
> <4>[ 6232.909027] Swap cache stats: add 0, delete 0, find 0/0
> <4>[ 6232.914764] Free swap =C2=A0=3D 0kB
> <4>[ 6232.917968] Total swap =3D 0kB

You don't have swap so VM can't reclaim anon pages to get a contiguous page=
.

> <4>[ 6232.945617] 131072 pages of RAM
> <4>[ 6232.949127] 17229 free pages
> <4>[ 6232.952270] 22953 reserved pages
> <4>[ 6232.955810] 5166 slab pages
> <4>[ 6232.958892] 123153 pages shared
> <4>[ 6232.962341] 0 pages swap cached
>

It means your system has 512M but 68M is reserved.
So you can use just 444M but anon is 278M. As I said, you can't
reclaim anon paes.
There is 67M free page but you can't use it as it's small pages but
you want big page.
slab : 20M page table : 18M kernel stack : 6M.
So 278 + 67 + 20 + 18 + 6 =3D 389M.
512M - 68M =3D 444.
Where is (444 - 389)?
I guess 55M is used by device driver and kernel. It's not accountable
in current kernel.

Solution
1. use CONFIG_COMPACTION=3Dy if you don't use.
2: consume small memory by application or device driver
3: use swap for reclaimaing anon pages
4 : buy bigger memory


> --
> Best Regards
> Hu Tao
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
