Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8334CC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 09:33:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32FB9213A2
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 09:33:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="n/5fz8Hc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32FB9213A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D226C8E0003; Wed, 27 Feb 2019 04:33:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD32E8E0001; Wed, 27 Feb 2019 04:33:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE91E8E0003; Wed, 27 Feb 2019 04:33:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 689228E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 04:33:56 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id b12so1520661wme.5
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 01:33:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=2J8ZHStak5huUflSrXmQipiG9UlMtxkIp962qvsRXZU=;
        b=oR1WuMxzm5vQZ9LOA+vkk3ej6gXGpWS1DZKq1VCTpA+wRuSurWwtCFdmWhS+dx0Gmr
         0rOtfDzLg+kV06geUDq873f6yEGPnOURw4UnAymUNxC+fHC131R4orhK2n0/1AAHaDBT
         j/uG2QhFMVJCLTPd4i2b1O0fZsajzrdQs6VvdS8FhzFAv42QZbADk1G9ytzlTEtzX+l2
         0abHTcL7v5Y35je44+t2m1cQXX4SUKT5Qavqx6xIH1bCjl9543iAZpCry4rA0WX/KJzw
         DDXpPSsX9xygIN+UT1cpiz5E23qAPcvI+qAnF1VWUOG2Jytf6kg+6qWKvLLDDwrNktUw
         f62Q==
X-Gm-Message-State: APjAAAVjA0+j3WRpVLgJCmHjkiWolhpnDv8w+abFFR1J29nSP/y5HQm8
	6Z7cGpUVm3rvTfecItl+Ek4YfBJC8soqVUttc4kC3tnGrhI98GETxCBfSL37uWAWHsEdzBolKTO
	z5rcUeBs9WyIxF639xtQtF0nHp7lFlQxpyqjU5x61a/pJJNZbsN9NBO+WEWPsanCDDg==
X-Received: by 2002:a5d:4e50:: with SMTP id r16mr1521842wrt.8.1551260035769;
        Wed, 27 Feb 2019 01:33:55 -0800 (PST)
X-Google-Smtp-Source: APXvYqypHDVIv4i4dwUGOhAiSjKboJZazCe69O3ffsT4G38W4QHggXM+vf7BxhPDvvLAiwz7eHwU
X-Received: by 2002:a5d:4e50:: with SMTP id r16mr1521788wrt.8.1551260034645;
        Wed, 27 Feb 2019 01:33:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551260034; cv=none;
        d=google.com; s=arc-20160816;
        b=iITOgH4+nNoLcfkBgkssdk77MJzVS7xiVj/ELd19jWcYCYAeO8jSeN2+BFgsNZAOyV
         mbN7sy78W76X0y0p6siXVEbmtJhmwQI2FpTwdxJD9tuhdwPkklik4buI/C7R2uO73zbb
         U9zjEgweJiHeuI6rCg7x6pBtd/DpVT7JztO8xjiK3l8EVLf9zSoFQafmFspNdvc+YJHr
         82/9Y4AtzcLEjHo6hzsaMPteD/9ZFxRzqJy9xdRkbqp9MedprIwDQbwrjAoaO1ZVjqco
         ZxgP6FBKJ/tNJ2Io+zLm4mPOdRRxmSyXY6KymuX3oRc3Bon8nbaQODG3Hjh+T8UZe+Fc
         A7rQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=2J8ZHStak5huUflSrXmQipiG9UlMtxkIp962qvsRXZU=;
        b=eRzARX8NxvI8XprS7jOv9tttc6Iu+yC4psbNrmAhWqnGzLLGfnZGrTxunkcvYGsfeX
         wH+ZBvBsr5UHg3W8iW1ONZWF45UvTkA/ozjI/tJDPBsYzNyWtApKXkKLMFVrg0UjeSUT
         fel2Oq9zYBD8n1KB6mhfVejt+E3dNIbHYy3FyKaLD248F5dtszM97Xo0Ho4GTmbzw/5h
         ORwpnubXpXRFSzdSm+iGPaJX8PehVGnZzSwWwP8ENPWNKhAx+XcyQv96jj81UxDcJfCB
         42Px24fAO7vwrv71OtPRRJQ7oiDxVb6rTSfetkAj88Imn4fJE4JvbAJ+sw5rQ9a+PtaZ
         oR9A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b="n/5fz8Hc";
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id j201si979939wmj.48.2019.02.27.01.33.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 01:33:54 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b="n/5fz8Hc";
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 448Vqj08s6z9tym3;
	Wed, 27 Feb 2019 10:33:53 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=n/5fz8Hc; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id 7BioI3QsAtIX; Wed, 27 Feb 2019 10:33:52 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 448Vqh66lQz9tym2;
	Wed, 27 Feb 2019 10:33:52 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551260032; bh=2J8ZHStak5huUflSrXmQipiG9UlMtxkIp962qvsRXZU=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=n/5fz8HclyPkav2T51NujPUuj1o/D2Q3VAcSMSRUwQ+HeAJGZDYMW5f4IB9emuUCs
	 OqAg46BENn9rbVDS4CyT/zz6/P7rZWcIa+xH/OsxwZNBK3BwrTcokDEXlj0R1YPvg8
	 hSsYMvUEtqvPIcl9Fh/RI5Mje9hCW6uKqi5n9dVA=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id E49E98B8B8;
	Wed, 27 Feb 2019 10:33:53 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id PqVpdgrTPRpE; Wed, 27 Feb 2019 10:33:53 +0100 (CET)
Received: from PO15451 (po15451.idsi0.si.c-s.fr [172.25.231.2])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id AE1F98B754;
	Wed, 27 Feb 2019 10:33:53 +0100 (CET)
Subject: Re: BUG: KASAN: stack-out-of-bounds
To: Dmitry Vyukov <dvyukov@google.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>, Daniel Axtens <dja@axtens.net>,
 Linux-MM <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org,
 kasan-dev <kasan-dev@googlegroups.com>
References: <c6d80735-0cfe-b4ab-0349-673fc65b2e15@c-s.fr>
 <5f0203bd-77ea-d94c-11b7-1befba439cd4@virtuozzo.com>
 <CACT4Y+Ze0Ezi4uKVZR1nk_EOjNcHd=JLhYq8ahqbfOL_8Jq9iw@mail.gmail.com>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <8e6f345b-679c-9e80-6917-b1953241b917@c-s.fr>
Date: Wed, 27 Feb 2019 10:33:53 +0100
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <CACT4Y+Ze0Ezi4uKVZR1nk_EOjNcHd=JLhYq8ahqbfOL_8Jq9iw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



Le 27/02/2019 à 10:25, Dmitry Vyukov a écrit :
> On Wed, Feb 27, 2019 at 10:18 AM Andrey Ryabinin
> <aryabinin@virtuozzo.com> wrote:
>> On 2/27/19 11:25 AM, Christophe Leroy wrote:
>>> With version v8 of the series implementing KASAN on 32 bits powerpc (https://patchwork.ozlabs.org/project/linuxppc-dev/list/?series=94309), I'm now able to activate KASAN on a mac99 is QEMU.
>>>
>>> Then I get the following reports at startup. Which of the two reports I get seems to depend on the option used to build the kernel, but for a given kernel I always get the same report.
>>>
>>> Is that a real bug, in which case how could I spot it ? Or is it something wrong in my implementation of KASAN ?
>>>
>>> I checked that after kasan_init(), the entire shadow memory is full of 0 only.
>>>
>>> I also made a try with the strong STACK_PROTECTOR compiled in, but no difference and nothing detected by the stack protector.
>>>
>>> ==================================================================
>>> BUG: KASAN: stack-out-of-bounds in memchr+0x24/0x74
>>> Read of size 1 at addr c0ecdd40 by task swapper/0
>>>
>>> CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1133
>>> Call Trace:
>>> [c0e9dca0] [c01c42a0] print_address_description+0x64/0x2bc (unreliable)
>>> [c0e9dcd0] [c01c4684] kasan_report+0xfc/0x180
>>> [c0e9dd10] [c089579c] memchr+0x24/0x74
>>> [c0e9dd30] [c00a9e38] msg_print_text+0x124/0x574
>>> [c0e9dde0] [c00ab710] console_unlock+0x114/0x4f8
>>> [c0e9de40] [c00adc60] vprintk_emit+0x188/0x1c4
>>> --- interrupt: c0e9df00 at 0x400f330
>>>      LR = init_stack+0x1f00/0x2000
>>> [c0e9de80] [c00ae3c4] printk+0xa8/0xcc (unreliable)
>>> [c0e9df20] [c0c28e44] early_irq_init+0x38/0x108
>>> [c0e9df50] [c0c16434] start_kernel+0x310/0x488
>>> [c0e9dff0] [00003484] 0x3484
>>>
>>> The buggy address belongs to the variable:
>>>   __log_buf+0xec0/0x4020
>>> The buggy address belongs to the page:
>>> page:c6eac9a0 count:1 mapcount:0 mapping:00000000 index:0x0
>>> flags: 0x1000(reserved)
>>> raw: 00001000 c6eac9a4 c6eac9a4 00000000 00000000 00000000 ffffffff 00000001
>>> page dumped because: kasan: bad access detected
>>>
>>> Memory state around the buggy address:
>>>   c0ecdc00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>>   c0ecdc80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>>> c0ecdd00: 00 00 00 00 00 00 00 00 f1 f1 f1 f1 00 00 00 00
>>>                                     ^
>>>   c0ecdd80: f3 f3 f3 f3 00 00 00 00 00 00 00 00 00 00 00 00
>>>   c0ecde00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>> ==================================================================
>>>
>>
>> This one doesn't look good. Notice that it says stack-out-of-bounds, but at the same time there is
>>          "The buggy address belongs to the variable:  __log_buf+0xec0/0x4020"
>>   which is printed by following code:
>>          if (kernel_or_module_addr(addr) && !init_task_stack_addr(addr)) {
>>                  pr_err("The buggy address belongs to the variable:\n");
>>                  pr_err(" %pS\n", addr);
>>          }
>>
>> So the stack unrelated address got stack-related poisoning. This could be a stack overflow, did you increase THREAD_SHIFT?
>> KASAN with stack instrumentation significantly increases stack usage.
> 
> A straightforward explanation would be that this happens before real
> shadow is mapped and we don't turn off KASAN reports. Should be easy
> to check so worth eliminating this possibility before any other
> debugging.
> 

I confirm this happens _after_ the call of kasan_init() which sets up 
the final shadow mapping. And after the call of kasan_init() I can 
confirm that the entire shadow area is zeroized.

kasan_init() is called at the top of setup_arch() which is called soon 
after the begining of start_kernel() (see 'KASAN init done' below).

early_irq_init() is called long after that.

Booting Linux via __start() @ 0x01000000 ...
Hello World !
Total memory = 128MB; using 256kB for hash table (at (ptrval))
Linux version 5.0.0-rc7+ (root@po16846vm.idsi0.si.c-s.fr) (gcc version 
5.4.0 (GCC)) #1133 Tue Feb 26 03:30:01 UTC 2019
KASAN init done
Found UniNorth memory controller & host bridge @ 0xf8000000 revision: 0x07
Mapped at 0xf77c0000
Found a Keylargo mac-io controller, rev: 0, mapped at 0x(ptrval)
PowerMac motherboard: PowerMac G4 AGP Graphics
boot stdout isn't a display !
Using PowerMac machine description
printk: bootconsole [udbg0] enabled
-----------------------------------------------------
Hash_size         = 0x40000
phys_mem_size     = 0x8000000
dcache_bsize      = 0x20
icache_bsize      = 0x20
cpu_features      = 0x000000000401a00a
   possible        = 0x000000002f7ff14b
   always          = 0x0000000000000000
cpu_user_features = 0x9c000001 0x00000000
mmu_features      = 0x00000001
Hash              = 0x(ptrval)
Hash_mask         = 0xfff
-----------------------------------------------------
Found UniNorth PCI host bridge at 0x00000000f2000000. Firmware bus 
number: 0->0
PCI host bridge /pci@f2000000 (primary) ranges:
   IO 0x00000000f2000000..0x00000000f27fffff -> 0x0000000000000000
  MEM 0x0000000080000000..0x000000008fffffff -> 0x0000000080000000
nvram: Checking bank 0...
Invalid signature
Invalid checksum
nvram: gen0=0, gen1=0
nvram: Active bank is: 0
nvram: OF partition at 0xffffffff
nvram: XP partition at 0xffffffff
nvram: NR partition at 0xffffffff
Zone ranges:
   Normal   [mem 0x0000000000000000-0x0000000007ffffff]
   HighMem  empty
Movable zone start for each node
Early memory node ranges
   node   0: [mem 0x0000000000000000-0x0000000007ffffff]
Initmem setup node 0 [mem 0x0000000000000000-0x0000000007ffffff]
Built 1 zonelists, mobility grouping on.  Total pages: 32512
Kernel command line: console=/dev/ttyS0
Dentry cache hash table entries: 16384 (order: 4, 65536 bytes)
Inode-cache hash table entries: 8192 (order: 3, 32768 bytes)
Memory: 93544K/131072K available (8868K kernel code, 1700K rwdata, 3484K 
rodata, 1004K init, 4434K bss, 37528K reserved, 0K cma-reserved, 0K highmem)
Kernel virtual memory layout:
   * 0xf8000000..0x00000000  : kasan shadow mem
   * 0xf7fd0000..0xf8000000  : fixmap
   * 0xf7800000..0xf7c00000  : highmem PTEs
   * 0xf6f36000..0xf7800000  : early ioremap
   * 0xc9000000..0xf6f36000  : vmalloc & ioremap
SLUB: HWalign=32, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
NR_IRQS: 512, nr_irqs: 512, preallocated irqs: 16
mpic: Setting up MPIC " MPIC 1   " version 1.2 at 80040000, max 1 CPUs
mpic: ISU size: 64, shift: 6, mask: 3f
mpic: Initializing for 64 sources
GMT Delta read from XPRAM: 0 minutes, DST: on
clocksource: timebase: mask: 0xffffffffffffffff max_cycles: 
0x171024e7e0, max_idle_ns: 440795205315 ns
clocksource: timebase mult[a000000] shift[24] registered
==================================================================
BUG: KASAN: stack-out-of-bounds in memchr+0x24/0x74
Read of size 1 at addr c0ecdd40 by task swapper/0

...

Christophe

