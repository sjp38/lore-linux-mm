Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id DC3226B0038
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 19:45:26 -0500 (EST)
Received: by mail-ob0-f177.google.com with SMTP id va2so3243436obc.36
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 16:45:26 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id s5si33774oib.69.2014.11.18.16.45.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Nov 2014 16:45:25 -0800 (PST)
Message-ID: <546BE7F2.3070009@oracle.com>
Date: Tue, 18 Nov 2014 19:44:34 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 00/11] Kernel address sanitizer - runtime memory debugger.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>	<1415199241-5121-1-git-send-email-a.ryabinin@samsung.com>	<546BD866.5050101@oracle.com> <CAPAsAGxYF27pbNEgsr3PgNJ=uNFzR2qcviLB_7bp=nM3ZD5Jgw@mail.gmail.com>
In-Reply-To: <CAPAsAGxYF27pbNEgsr3PgNJ=uNFzR2qcviLB_7bp=nM3ZD5Jgw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Michal Marek <mmarek@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Randy Dunlap <rdunlap@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Jones <davej@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joe Perches <joe@perches.com>, LKML <linux-kernel@vger.kernel.org>

On 11/18/2014 07:09 PM, Andrey Ryabinin wrote:
> Yes with CONFIG_KASAN_INLINE you will get GPF instead of kasan report.
> For userspaces addresses we don't have shadow memory. In outline case
> I just check address itself before checking shadow. In inline case compiler
> just checks shadow, so there is no way to avoid GPF.
> 
> To be able to print report instead of GPF, I need to treat GPFs in a special
> way if inline instrumentation was enabled, but it's not done yet.

I went ahead and tested it with the test module, which worked perfectly. No
more complaints here...

>> > I remembered that one of the biggest changes in kasan was the introduction of
>> > inline instrumentation, so I went ahead to disable it and see if it helps. But
>> > the only result of that was having the boot process hang pretty early:
>> >
>> > [...]
>> > [    0.000000] IOAPIC[0]: apic_id 21, version 17, address 0xfec00000, GSI 0-23
>> > [    0.000000] Processors: 20
>> > [    0.000000] smpboot: Allowing 24 CPUs, 4 hotplug CPUs
>> > [    0.000000] e820: [mem 0xd0000000-0xffffffff] available for PCI devices
>> > [    0.000000] Booting paravirtualized kernel on KVM
>> > [    0.000000] setup_percpu: NR_CPUS:8192 nr_cpumask_bits:24 nr_cpu_ids:24 nr_node_ids:1
>> > [    0.000000] PERCPU: Embedded 491 pages/cpu @ffff8808dce00000 s1971864 r8192 d31080 u2097152
>> > *HANG*
>> >
> This hang happens only with your error patch above or even without it?

It happens even without the patch.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
