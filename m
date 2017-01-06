Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id F3DD36B0038
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 23:49:53 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id m67so347195855qkf.0
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 20:49:53 -0800 (PST)
Received: from mail-qt0-x241.google.com (mail-qt0-x241.google.com. [2607:f8b0:400d:c0d::241])
        by mx.google.com with ESMTPS id 16si39585783qkj.221.2017.01.05.20.49.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 20:49:53 -0800 (PST)
Received: by mail-qt0-x241.google.com with SMTP id w39so6719942qtw.0
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 20:49:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <cbbf14fd-a1cc-2463-ba67-acd6d61e9db1@linaro.org>
References: <20161216165437.21612-1-rrichter@cavium.com> <CAKv+Gu_SmTNguC=tSCwYOL2kx-DogLvSYRZc56eGP=JhdrUOsA@mail.gmail.com>
 <c74d6ec6-16ba-dccc-3b0d-a8bedcb46dc5@linaro.org> <cbbf14fd-a1cc-2463-ba67-acd6d61e9db1@linaro.org>
From: Prakash B <bjsprakash.linux@gmail.com>
Date: Fri, 6 Jan 2017 10:19:52 +0530
Message-ID: <CACJhumcO7tvYOptyBSc9PDt29ogFCdMvEHmQ0Hib9Zts-eeZSA@mail.gmail.com>
Subject: Re: [PATCH v3] arm64: mm: Fix NOMAP page initialization
Content-Type: multipart/alternative; boundary=001a11358752a76478054565bf80
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hanjun Guo <hanjun.guo@linaro.org>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Robert Richter <rrichter@cavium.com>, Mark Rutland <mark.rutland@arm.com>, Yisheng Xie <xieyisheng1@huawei.com>, David Daney <david.daney@cavium.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Russell King <linux@armlinux.org.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, James Morse <james.morse@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

--001a11358752a76478054565bf80
Content-Type: text/plain; charset=UTF-8

Hi Hanjun,

a update here, tested on 4.9,

>
>  - Applied Ard's two patches only
>  - Applied Robert's patch only
>
> Both of them can work fine on D05 with NUMA enabled, which means
> boot ok and LTP MM stress test is passed.
>

It's not related to this patch set.
LTP "cpuset01" test  crashes with latest 4.9,  4.10-rc1 and 4.10-rc2
kernels on Thunderx 2S .  Do you see any such behaviour on D05.
Any idea what might be causing this issue.


  227.627546] cpuset01: page allocation stalls for 10096ms, order:0,
mode:0x24200ca(GFP_HIGHUSER_MOVABLE)
[  227.627586] CPU: 53 PID: 11017 Comm: cpuset01 Not tainted 4.9.04kNUMA+ #2
[  227.627591] Hardware name: www.cavium.com ThunderX Unknown/ThunderX
Unknown, BIOS 0.3 Aug 24 2016
[  227.627599] Call trace:
[  227.627623] [<ffff000008089f10>] dump_backtrace+0x0/0x238
[  227.627640] [<ffff00000808a16c>] show_stack+0x24/0x30
[  227.627656] [<ffff00000846fb50>] dump_stack+0x94/0xb4
[  227.627679] [<ffff0000081eb4f8>] warn_alloc+0x138/0x150
[  227.627686] [<ffff0000081ec0a4>] __alloc_pages_nodemask+0xb04/0xcf0
[  227.627697] [<ffff000008245988>] alloc_pages_vma+0xc8/0x270
[  227.627715] [<ffff00000821f604>] handle_mm_fault+0xc8c/0xfd8
[  227.627732] [<ffff00000809a488>] do_page_fault+0x2c0/0x368
[  227.627744] [<ffff0000080812ec>] do_mem_abort+0x6c/0xe0
[  227.627752] Exception stack(0xffff801f55823e00 to 0xffff801f55823f30)
[  227.627763] 3e00: 0000000000000000 0000ffff92682000
ffffffffffffffff 0000ffff9252b3e8
[  227.627774] 3e20: 0000000020000000 0000000000000000
000000000000a000 0000000000000003
[  227.627785] 3e40: 0000000000000022 ffffffffffffffff
0000000000000123 00000000000000de
[  227.627793] 3e60: ffff000008972000 0000000000000015
ffff801f55823e90 0000000000040900
[  227.627800] 3e80: 0000000000000000 ffff0000080836f0
0000000000000000 0000ffff92682000
[  227.627809] 3ea0: ffffffffffffffff 0000ffff92575d8c
0000000000000000 0000000000040900
[  227.627819] 3ec0: 0000ffff92682000 00000000000000f7
0000000000004fc0 0000000000000022
[  227.627828] 3ee0: 0000000000000000 0000000000000000
0000ffff925f5508 f7f7f7f7f7f7f7f7
[  227.627838] 3f00: 0000ffff92686ff0 0000000000002ab8
0101010101010101 0000000000000020
[  227.627847] 3f20: 0000000000000000 0000000000000000
[  227.627858] [<ffff000008083324>] el0_da+0x18/0x1c
[  227.627865] Mem-Info:
[  227.627899] active_anon:38613 inactive_anon:8174 isolated_anon:0
                active_file:25148 inactive_file:64173 isolated_file:0
                unevictable:742 dirty:0 writeback:0 unstable:0
                slab_reclaimable:29066 slab_unreclaimable:67304
                mapped:22876 shmem:2597 pagetables:1240 bounce:0
                free:65582521 free_pcp:1834 free_cma:0



>
> I'm not familiar with memory management, it's up to you guys to make
> a decision :)
>
>
> Thanks
> Hanjun
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>

--001a11358752a76478054565bf80
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi Hanjun,<br><br>a update here, tested on 4.9,<br><div cl=
ass=3D"gmail_extra"><div class=3D"gmail_quote"><blockquote class=3D"gmail_q=
uote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,2=
04);padding-left:1ex">
<br>
=C2=A0- Applied Ard&#39;s two patches only<br>
=C2=A0- Applied Robert&#39;s patch only<br>
<br>
Both of them can work fine on D05 with NUMA enabled, which means<br>
boot ok and LTP MM stress test is passed.<br></blockquote><div><br></div><d=
iv>It&#39;s not related to this patch set.<br>LTP &quot;cpuset01&quot; test=
=C2=A0 crashes with latest 4.9,=C2=A0 4.10-rc1 and 4.10-rc2 kernels on Thun=
derx 2S .=C2=A0 Do you see any such behaviour on D05.<br></div><div>Any ide=
a what might be causing this issue.<br></div><div><br><br><pre class=3D"gma=
il-bz_comment_text" id=3D"gmail-comment_text_0">  227.627546] cpuset01: pag=
e allocation stalls for 10096ms, order:0, mode:0x24200ca(GFP_HIGHUSER_MOVAB=
LE)
[  227.627586] CPU: 53 PID: 11017 Comm: cpuset01 Not tainted 4.9.04kNUMA+ #=
2
[  227.627591] Hardware name: <a href=3D"http://www.cavium.com">www.cavium.=
com</a> ThunderX Unknown/ThunderX Unknown, BIOS 0.3 Aug 24 2016
[  227.627599] Call trace:
[  227.627623] [&lt;ffff000008089f10&gt;] dump_backtrace+0x0/0x238
[  227.627640] [&lt;ffff00000808a16c&gt;] show_stack+0x24/0x30
[  227.627656] [&lt;ffff00000846fb50&gt;] dump_stack+0x94/0xb4
[  227.627679] [&lt;ffff0000081eb4f8&gt;] warn_alloc+0x138/0x150
[  227.627686] [&lt;ffff0000081ec0a4&gt;] __alloc_pages_nodemask+0xb04/0xcf=
0
[  227.627697] [&lt;ffff000008245988&gt;] alloc_pages_vma+0xc8/0x270
[  227.627715] [&lt;ffff00000821f604&gt;] handle_mm_fault+0xc8c/0xfd8
[  227.627732] [&lt;ffff00000809a488&gt;] do_page_fault+0x2c0/0x368
[  227.627744] [&lt;ffff0000080812ec&gt;] do_mem_abort+0x6c/0xe0
[  227.627752] Exception stack(0xffff801f55823e00 to 0xffff801f55823f30)
[  227.627763] 3e00: 0000000000000000 0000ffff92682000 ffffffffffffffff 000=
0ffff9252b3e8
[  227.627774] 3e20: 0000000020000000 0000000000000000 000000000000a000 000=
0000000000003
[  227.627785] 3e40: 0000000000000022 ffffffffffffffff 0000000000000123 000=
00000000000de
[  227.627793] 3e60: ffff000008972000 0000000000000015 ffff801f55823e90 000=
0000000040900
[  227.627800] 3e80: 0000000000000000 ffff0000080836f0 0000000000000000 000=
0ffff92682000
[  227.627809] 3ea0: ffffffffffffffff 0000ffff92575d8c 0000000000000000 000=
0000000040900
[  227.627819] 3ec0: 0000ffff92682000 00000000000000f7 0000000000004fc0 000=
0000000000022
[  227.627828] 3ee0: 0000000000000000 0000000000000000 0000ffff925f5508 f7f=
7f7f7f7f7f7f7
[  227.627838] 3f00: 0000ffff92686ff0 0000000000002ab8 0101010101010101 000=
0000000000020
[  227.627847] 3f20: 0000000000000000 0000000000000000
[  227.627858] [&lt;ffff000008083324&gt;] el0_da+0x18/0x1c
[  227.627865] Mem-Info:
[  227.627899] active_anon:38613 inactive_anon:8174 isolated_anon:0
                active_file:25148 inactive_file:64173 isolated_file:0
                unevictable:742 dirty:0 writeback:0 unstable:0
                slab_reclaimable:29066 slab_unreclaimable:67304
                mapped:22876 shmem:2597 pagetables:1240 bounce:0
                free:65582521 free_pcp:1834 free_cma:0</pre></div><div>=C2=
=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8e=
x;border-left:1px solid rgb(204,204,204);padding-left:1ex">
<br>
I&#39;m not familiar with memory management, it&#39;s up to you guys to mak=
e<br>
a decision :)<div class=3D"gmail-HOEnZb"><div class=3D"gmail-h5"><br>
<br>
Thanks<br>
Hanjun<br>
<br>
______________________________<wbr>_________________<br>
linux-arm-kernel mailing list<br>
<a href=3D"mailto:linux-arm-kernel@lists.infradead.org" target=3D"_blank">l=
inux-arm-kernel@lists.infrade<wbr>ad.org</a><br>
<a href=3D"http://lists.infradead.org/mailman/listinfo/linux-arm-kernel" re=
l=3D"noreferrer" target=3D"_blank">http://lists.infradead.org/mai<wbr>lman/=
listinfo/linux-arm-kernel</a><br>
</div></div></blockquote></div><br></div></div>

--001a11358752a76478054565bf80--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
