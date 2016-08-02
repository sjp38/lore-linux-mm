Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 05B006B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 05:53:08 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p129so99570353wmp.3
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 02:53:07 -0700 (PDT)
Received: from jowisz.mejor.pl (jowisz.mejor.pl. [2001:470:1f15:1b61::2])
        by mx.google.com with ESMTPS id p71si2329880wmf.51.2016.08.02.02.53.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 02:53:05 -0700 (PDT)
Subject: Re: Choosing z3fold allocator in zswap gives WARNING: CPU: 0 PID:
 5140 at mm/zswap.c:503 __zswap_pool_current+0x56/0x60
References: <2f8a65db-e5a8-75f0-8c08-daa41e1cd3ba@mejor.pl>
 <CAM4kBBLsK99PXaCa8Po3huOyGx+qHTrq3Vgsh+FoqqRaMLv-vQ@mail.gmail.com>
 <15aabbf1-4036-cd15-a593-3ebfe429e948@mejor.pl>
 <CAM4kBBL03Qi=iBo9BHfrxv8OXdpMV1DFccm+C9VF1stCTivnzg@mail.gmail.com>
From: =?UTF-8?Q?Marcin_Miros=c5=82aw?= <marcin@mejor.pl>
Message-ID: <c3b83e70-5c41-8259-37bf-4c194bd59f4b@mejor.pl>
Date: Tue, 2 Aug 2016 11:52:47 +0200
MIME-Version: 1.0
In-Reply-To: <CAM4kBBL03Qi=iBo9BHfrxv8OXdpMV1DFccm+C9VF1stCTivnzg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitaly.wool@konsulko.com>
Cc: Linux-MM <linux-mm@kvack.org>

W dniu 02.08.2016 o 11:13, Vitaly Wool pisze:
> 
> 
> On Mon, Aug 1, 2016 at 11:21 AM, Marcin MirosA?aw <marcin@mejor.pl
> <mailto:marcin@mejor.pl>> wrote:
> 
>     W dniu 01.08.2016 o 11:08, Vitaly Wool pisze:
>     > Hi Marcin,
>     >
>     > Den 1 aug. 2016 11:04 fm skrev "Marcin MirosA?aw" <marcin@mejor.pl <mailto:marcin@mejor.pl>
>     > <mailto:marcin@mejor.pl <mailto:marcin@mejor.pl>>>:
>     >>
>     >> Hi!
>     >> I'm testing kernel-git
>     >> (git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
>     <http://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git>
>     >
>     <http://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git> , at
>     >> 07f00f06ba9a5533d6650d46d3e938f6cbeee97e ) because I noticed strange OOM
>     >> behavior in kernel 4.7.0. As for now I can't reproduce problems with
>     >> OOM, probably it's fixed now.
>     >> But now I wanted to try z3fold with zswap. When I did `echo z3fold >
>     >> /sys/module/zswap/parameters/zpool` I got trace from dmesg:
>     >
>     > Could you please give more info on how to reproduce this?
> 
>     Nothing special. Just rebooted server (vm on kvm), started services and
>     issued `echo z3fold > ...`
> 
> 
> Well, first of all this is Intel right?


Yes, this is Intel and I'm sitting inside vm (KVM).
[...]
processor       : 3
vendor_id       : GenuineIntel
cpu family      : 6
model           : 62
model name      : Intel(R) Xeon(R) CPU E5-2630 v2 @ 2.60GHz
stepping        : 4
microcode       : 0x1
cpu MHz         : 2599.851
cache size      : 4096 KB
physical id     : 3
siblings        : 1
core id         : 0
cpu cores       : 1
apicid          : 3
initial apicid  : 3
fpu             : yes
fpu_exception   : yes
cpuid level     : 13
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 clflush mmx fxsr sse sse2 ss syscall nx pdpe1gb lm
constant_tsc arch_perfmon nopl eagerfpu pni pclmulqdq ssse3 cx16 pcid
sse4_1 sse4_2 x2apic popcnt tsc_deadline_timer aes xsave avx f16c rdrand
hypervisor lahf_lm fsgsbase smep xsaveopt
bugs            :
bogomips        : 5199.99
clflush size    : 64
cache_alignment : 64
address sizes   : 46 bits physical, 48 bits virtual
power management:

I've got 4 VCPU.

Marcin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
