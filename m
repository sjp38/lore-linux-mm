Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id BDD4238D5A
	for <linux-mm@kvack.org>; Wed, 22 Aug 2001 16:26:04 -0300 (EST)
Date: Wed, 22 Aug 2001 16:25:49 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: VM problem with 2.4.8-ac9 (fwd)
Message-ID: <Pine.LNX.4.33L.0108221622160.31410-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-mm@kvack.org, Marcelo Tosatti <marcelo@conectiva.com.br>, Jari Ruusu <jari.ruusu@pp.inet.fi>
List-ID: <linux-mm.kvack.org>

Hi Alan,

Another report of tasks dying on recent 2.4 kernels.
Suspect code would be:
- tlb optimisations in recent -ac    (tasks dying with segfault)
- swapfile.c, especially sys_swapoff (known race condition, marcelo?)

What would cause the swap map badness below I wouldn't know,
maybe marcelo is more familiar with the swapfile.c code...

regards,

Rik
--
IA64: a worthy successor to the i860.
---------- Forwarded message ----------
Date: Wed, 22 Aug 2001 20:37:01 +0300
From: Jari Ruusu <jari.ruusu@pp.inet.fi>
To: Rik van Riel <riel@conectiva.com.br>
Subject: VM problem with 2.4.8-ac9

Unused swap offset entry in swap_dup 00519e00
VM: Bad swap entry 00519e00
Unused swap offset entry in swap_count 00519e00
Unused swap offset entry in swap_count 00519e00
VM: Bad swap entry 00519e00
Unused swap offset entry in swap_dup 006b8a00
VM: Bad swap entry 006b8a00
Unused swap offset entry in swap_dup 006b8a00
VM: killing process nscd
Unused swap offset entry in swap_dup 006b8a00
VM: killing process nscd
VM: Bad swap entry 006b8a00
Unused swap offset entry in swap_dup 005e6900
VM: Bad swap entry 005e6900
Unused swap offset entry in swap_dup 005e6900
VM: killing process init
Unused swap offset entry in swap_dup 005e6900
VM: killing process init
Unused swap offset entry in swap_dup 005e6900
VM: killing process init
Unused swap offset entry in swap_dup 005e6900
VM: killing process init
Kernel panic: Attempted to kill init!

Linux debian 2.4.8-ac9 #1 Wed Aug 22 16:04:25 EEST 2001 i686 unknown
Gnu C                  2.95.3
Gnu make               3.79.1
binutils               2.9.5.0.37
mount                  2.11g
modutils               2.4.6
e2fsprogs              1.18
PPP                    2.3.11
Linux C Library        2.1.3
ldd: version 1.9.11
Procps                 2.0.6
Net-tools              1.54
Console-tools          0.2.3
Sh-utils               2.0

I get a repeatable VM failure with recent 2.4 kernels, tested with
2.4.8-ac[789] on x86 architecture. My VM torture test consists of following:
boot the kernel with "mem=16M" parameter, start X11 and a couple xterms
running kernel compile, glibc compile, bzip2 decompressor + tar, and top.
Also xosview was running. Working memory need of such setup is way over
available RAM, and swap use was about 20-35 MB (of 190 MB available swap),
and swapping activity was _continuous_. Kernel 2.2.19aa2 survives the
torture (everything else being same), and memtest-86 does not find any
errors, so it is unlikely to be hardware failure.

Anyway, the box dies after about 1-3 hours of torture. Sometimes it just
kills some random process. I captured above info using serial console. If
you need more info (.config, System.map, whatever) just ask for it. I am
willing to do more testing, just tell me what you need done.

Regards,
Jari Ruusu <jari.ruusu@pp.inet.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
