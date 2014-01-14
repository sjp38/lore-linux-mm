Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id D508E6B0031
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 20:12:32 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id jt11so8046247pbb.36
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 17:12:32 -0800 (PST)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id s4si17207460pbg.123.2014.01.13.17.12.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 13 Jan 2014 17:12:31 -0800 (PST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 84AD03EE0C1
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 10:12:29 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7476B45DE69
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 10:12:26 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.nic.fujitsu.com [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D0A345DE5A
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 10:12:26 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F9DAE08006
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 10:12:26 +0900 (JST)
Received: from g01jpfmpwyt03.exch.g01.fujitsu.local (g01jpfmpwyt03.exch.g01.fujitsu.local [10.128.193.57])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EBC7F1DB8047
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 10:12:25 +0900 (JST)
Message-ID: <52D48EC4.5070400@jp.fujitsu.com>
Date: Tue, 14 Jan 2014 10:11:32 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86, acpi memory hotplug, add parameter to disable memory
 hotplug
References: <1389650161-13292-1-git-send-email-prarit@redhat.com> <CAHGf_=pX303E6VAhL+gApSQ1OsEQHqTuCN8ZSdD3E54YAcFQKA@mail.gmail.com> <52D47999.5080905@redhat.com>
In-Reply-To: <52D47999.5080905@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prarit Bhargava <prarit@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Len Brown <lenb@kernel.org>, "Rafael J.
 Wysocki" <rjw@rjwysocki.net>, Linn Crosetto <linn@hp.com>, Pekka Enberg <penberg@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Young <dyoung@redhat.com>, linux-acpi@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

(2014/01/14 8:41), Prarit Bhargava wrote:
>
>
> On 01/13/2014 05:17 PM, KOSAKI Motohiro wrote:
>> On Mon, Jan 13, 2014 at 4:56 PM, Prarit Bhargava <prarit@redhat.com> wrote:
>>> When booting a kexec/kdump kernel on a system that has specific memory hotplug
>>> regions the boot will fail with warnings like:
>>>
>>> [    2.939467] swapper/0: page allocation failure: order:9, mode:0x84d0
>>> [    2.946564] CPU: 0 PID: 1 Comm: swapper/0 Not tainted
>>> 3.10.0-65.el7.x86_64 #1
>>> [    2.954532] Hardware name: QCI QSSC-S4R/QSSC-S4R, BIOS
>>> QSSC-S4R.QCI.01.00.S013.032920111005 03/29/2011
>>> [    2.964926]  0000000000000000 ffff8800341bd8c8 ffffffff815bcc67
>>> ffff8800341bd950
>>> [    2.973224]  ffffffff8113b1a0 ffff880036339b00 0000000000000009
>>> 00000000000084d0
>>> [    2.981523]  ffff8800341bd950 ffffffff815b87ee 0000000000000000
>>> 0000000000000200
>>> [    2.989821] Call Trace:
>>> [    2.992560]  [<ffffffff815bcc67>] dump_stack+0x19/0x1b
>>> [    2.998300]  [<ffffffff8113b1a0>] warn_alloc_failed+0xf0/0x160
>>> [    3.004817]  [<ffffffff815b87ee>] ?
>>> __alloc_pages_direct_compact+0xac/0x196
>>> [    3.012594]  [<ffffffff8113f14f>] __alloc_pages_nodemask+0x7ff/0xa00
>>> [    3.019692]  [<ffffffff815b417c>] vmemmap_alloc_block+0x62/0xba
>>> [    3.026303]  [<ffffffff815b41e9>] vmemmap_alloc_block_buf+0x15/0x3b
>>> [    3.033302]  [<ffffffff815b1ff6>] vmemmap_populate+0xb4/0x21b
>>> [    3.039718]  [<ffffffff815b461d>] sparse_mem_map_populate+0x27/0x35
>>> [    3.046717]  [<ffffffff815b400f>] sparse_add_one_section+0x7a/0x185
>>> [    3.053720]  [<ffffffff815a1e9f>] __add_pages+0xaf/0x240
>>> [    3.059656]  [<ffffffff81047359>] arch_add_memory+0x59/0xd0
>>> [    3.065877]  [<ffffffff815a21d9>] add_memory+0xb9/0x1b0
>>> [    3.071713]  [<ffffffff81333b9c>] acpi_memory_device_add+0x18d/0x26d
>>> [    3.078813]  [<ffffffff81309a01>] acpi_bus_device_attach+0x7d/0xcd
>>> [    3.085719]  [<ffffffff8132379d>] acpi_ns_walk_namespace+0xc8/0x17f
>>> [    3.092716]  [<ffffffff81309984>] ? acpi_bus_type_and_status+0x90/0x90
>>> [    3.100004]  [<ffffffff81309984>] ? acpi_bus_type_and_status+0x90/0x90
>>> [    3.107293]  [<ffffffff81323c8c>] acpi_walk_namespace+0x95/0xc5
>>> [    3.113904]  [<ffffffff8130a6d6>] acpi_bus_scan+0x8b/0x9d
>>> [    3.119933]  [<ffffffff81a2019a>] acpi_scan_init+0x63/0x160
>>> [    3.126153]  [<ffffffff81a1ffb5>] acpi_init+0x25d/0x2a6
>>> [    3.131987]  [<ffffffff81a1fd58>] ? acpi_sleep_proc_init+0x2a/0x2a
>>> [    3.138889]  [<ffffffff810020e2>] do_one_initcall+0xe2/0x190
>>> [    3.145210]  [<ffffffff819e20c4>] kernel_init_freeable+0x17c/0x207
>>> [    3.152111]  [<ffffffff819e18d0>] ? do_early_param+0x88/0x88
>>> [    3.158430]  [<ffffffff8159fea0>] ? rest_init+0x80/0x80
>>> [    3.164264]  [<ffffffff8159feae>] kernel_init+0xe/0x180
>>> [    3.170097]  [<ffffffff815cca2c>] ret_from_fork+0x7c/0xb0
>>> [    3.176123]  [<ffffffff8159fea0>] ? rest_init+0x80/0x80
>>> [    3.181956] Mem-Info:
>>> [    3.184490] Node 0 DMA per-cpu:
>>> [    3.188007] CPU    0: hi:    0, btch:   1 usd:   0
>>> [    3.193353] Node 0 DMA32 per-cpu:
>>> [    3.197060] CPU    0: hi:   42, btch:   7 usd:   0
>>> [    3.202410] active_anon:0 inactive_anon:0 isolated_anon:0
>>> [    3.202410]  active_file:0 inactive_file:0 isolated_file:0
>>> [    3.202410]  unevictable:0 dirty:0 writeback:0 unstable:0
>>> [    3.202410]  free:872 slab_reclaimable:13 slab_unreclaimable:1880
>>> [    3.202410]  mapped:0 shmem:0 pagetables:0 bounce:0
>>> [    3.202410]  free_cma:0
>>>
>>> because the system has run out of memory at boot time.  This occurs
>>> because of the following sequence in the boot:
>>>
>>> Main kernel boots and sets E820 map.  The second kernel is booted with a
>>> map generated by the kdump service using memmap= and memmap=exactmap.
>>> These parameters are added to the kernel parameters of the kexec/kdump
>>> kernel.   The kexec/kdump kernel has limited memory resources so as not
>>> to severely impact the main kernel.
>>>
>>> The system then panics and the kdump/kexec kernel boots (which is a
>>> completely new kernel boot).  During this boot ACPI is initialized and the
>>> kernel (as can be seen above) traverses the ACPI namespace and finds an
>>> entry for a memory device to be hotadded.
>>>
>>> ie)
>>>
>>> [    3.053720]  [<ffffffff815a1e9f>] __add_pages+0xaf/0x240
>>> [    3.059656]  [<ffffffff81047359>] arch_add_memory+0x59/0xd0
>>> [    3.065877]  [<ffffffff815a21d9>] add_memory+0xb9/0x1b0
>>> [    3.071713]  [<ffffffff81333b9c>] acpi_memory_device_add+0x18d/0x26d
>>> [    3.078813]  [<ffffffff81309a01>] acpi_bus_device_attach+0x7d/0xcd
>>> [    3.085719]  [<ffffffff8132379d>] acpi_ns_walk_namespace+0xc8/0x17f
>>> [    3.092716]  [<ffffffff81309984>] ? acpi_bus_type_and_status+0x90/0x90
>>> [    3.100004]  [<ffffffff81309984>] ? acpi_bus_type_and_status+0x90/0x90
>>> [    3.107293]  [<ffffffff81323c8c>] acpi_walk_namespace+0x95/0xc5
>>> [    3.113904]  [<ffffffff8130a6d6>] acpi_bus_scan+0x8b/0x9d
>>> [    3.119933]  [<ffffffff81a2019a>] acpi_scan_init+0x63/0x160
>>> [    3.126153]  [<ffffffff81a1ffb5>] acpi_init+0x25d/0x2a6
>>>
>>> At this point the kernel adds page table information and the the kexec/kdump
>>> kernel runs out of memory.
>>>
>>> This can also be reproduced with a "regular" kernel by using the
>>> memmap=exactmap and mem=X parameters on the main kernel and booting.
>>>
>>> This patchset resolves the problem by adding a kernel parameter,
>>> acpi_no_memhotplug, to disable ACPI memory hotplug.  ACPI memory hotplug
>>> should also be disabled by default when a user specified a memory mapping with
>>> "memmap=exactmap" or "mem=X".
>>>
>>> Signed-off-by: Prarit Bhargava <prarit@redhat.com>
>>> Cc: Thomas Gleixner <tglx@linutronix.de>
>>> Cc: Ingo Molnar <mingo@redhat.com>
>>> Cc: "H. Peter Anvin" <hpa@zytor.com>
>>> Cc: x86@kernel.org
>>> Cc: Len Brown <lenb@kernel.org>
>>> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
>>> Cc: Linn Crosetto <linn@hp.com>
>>> Cc: Pekka Enberg <penberg@kernel.org>
>>> Cc: Yinghai Lu <yinghai@kernel.org>
>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>> Cc: Toshi Kani <toshi.kani@hp.com>
>>> Cc: Tang Chen <tangchen@cn.fujitsu.com>
>>> Cc: Wen Congyang <wency@cn.fujitsu.com>
>>> Cc: Vivek Goyal <vgoyal@redhat.com>
>>> Cc: kosaki.motohiro@gmail.com
>>> Cc: dyoung@redhat.com
>>> Cc: Toshi Kani <toshi.kani@hp.com>
>>> Cc: linux-acpi@vger.kernel.org
>>> Cc: linux-mm@kvack.org
>>
>> I think we need a knob manually enable mem-hotplug when specify memmap. But
>> it is another story.
>>
>> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>
> As mentioned, self-NAK.  I have seen a system that I needed to specify
> memmap=exactmap & had hotplug memory.  I will only keep the acpi_no_memhotplug
> option in the next version of the patch.


Your following first patch is simply and makes sense.

http://marc.info/?l=linux-acpi&m=138922019607796&w=2

Thanks,
Yasuaki Ishiamtsu

>
> P.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
