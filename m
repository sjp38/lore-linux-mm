Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 92D836B069F
	for <linux-mm@kvack.org>; Fri, 18 May 2018 19:26:05 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id i3-v6so11557248iti.1
        for <linux-mm@kvack.org>; Fri, 18 May 2018 16:26:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k81-v6sor5331234iod.251.2018.05.18.16.26.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 May 2018 16:26:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJwJo6Y1+Zrriox6WTZtFhDuUkMRed3FXv8Nte=YLgkQd3p9vw@mail.gmail.com>
References: <20180517233510.24996-1-dima@arista.com> <1526600442.28243.39.camel@arista.com>
 <CALCETrUDX=4FHU0e8SZ9Rr_AnAes+5jjzKCrrVmS1mddHQyeVQ@mail.gmail.com>
 <CAJwJo6ZwEZiQYDQqLkfP0+mRgmc+X=H02M=fFZZykWN4A3s-FQ@mail.gmail.com> <CAJwJo6Y1+Zrriox6WTZtFhDuUkMRed3FXv8Nte=YLgkQd3p9vw@mail.gmail.com>
From: Dmitry Safonov <0x7f454c46@gmail.com>
Date: Sat, 19 May 2018 00:25:44 +0100
Message-ID: <CAJwJo6aUp-SyVkJH0CEQ7sVNE2gX2eagGJ6JGvWa8Ar5rM6sQg@mail.gmail.com>
Subject: Re: [PATCH] x86/mm: Drop TS_COMPAT on 64-bit exec() syscall
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Dmitry Safonov <dima@arista.com>, LKML <linux-kernel@vger.kernel.org>, izbyshev@ispras.ru, Alexander Monakov <amonakov@ispras.ru>, Borislav Petkov <bp@suse.de>, Cyrill Gorcunov <gorcunov@openvz.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Linux-MM <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, stable <stable@vger.kernel.org>

2018-05-19 0:16 GMT+01:00 Dmitry Safonov <0x7f454c46@gmail.com>:
> 2018-05-19 0:10 GMT+01:00 Dmitry Safonov <0x7f454c46@gmail.com>:
>> Sure.
>> I'm on Intel actually:
>> cpu family    : 6
>> model        : 142
>> model name    : Intel(R) Core(TM) i7-7600U CPU @ 2.80GHz
>>
>> But I usually test kernels in VM. So, I use virt-manager as it's
>> easier to manage
>> multiple VMs. The thing is that I've chosen "Copy host CPU configuration"
>> and for some reason, I don't quite follow virt-manager makes model "Opteron_G4".
>> I'm on Fedora 27, virt-manager 1.4.3, qemu 2.9.1(qemu-2.9.1-2.fc26).
>
> Hmm, the reason it chooses AMD emulation looks like a bug in virt-manager:
> When I try IvyBridge CPU, it gives the following error:
>> Error starting domain: the CPU is incompatible with host CPU: Host CPU does not
>> provide required features: vme, x2apic, tsc-deadline, avx, f16c, rdrand
>
> Which to my naive mind is by the reason that "tsc-deadline" is not written with
> a dash in cpuinfo:
> flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
> mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe
> syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts
> rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq
> pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma
> cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt
> tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch
> cpuid_fault epb invpcid_single pti tpr_shadow vnmi flexpriority ept
> vpid fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx
> rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves
> ibpb ibrs stibp dtherm ida arat pln pts hwp hwp_notify hwp_act_window
> hwp_epp
>
> But that just my naive suppose.

Yeah, so they use cpuid there and I guess this one wasn't fixed for me:
https://bugzilla.redhat.com/show_bug.cgi?id=1467599

Thanks,
             Dmitry
