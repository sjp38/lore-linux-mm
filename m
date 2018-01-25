Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 06FC96B0005
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 17:09:46 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id e26so6931348pfi.15
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 14:09:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 1-v6sor1224284plv.17.2018.01.25.14.09.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jan 2018 14:09:44 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [RFC PATCH 00/16] PTI support for x86-32
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20180124185800.GA11515@shrek.podlesie.net>
Date: Thu, 25 Jan 2018 14:09:40 -0800
Content-Transfer-Encoding: 7bit
Message-Id: <67E8EB67-EB60-441E-BDFB-521F3D431400@gmail.com>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <20180124185800.GA11515@shrek.podlesie.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Mazur <krzysiek@podlesie.net>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>

Krzysztof Mazur <krzysiek@podlesie.net> wrote:

> On Tue, Jan 16, 2018 at 05:36:43PM +0100, Joerg Roedel wrote:
>> From: Joerg Roedel <jroedel@suse.de>
>> 
>> Hi,
>> 
>> here is my current WIP code to enable PTI on x86-32. It is
>> still in a pretty early state, but it successfully boots my
>> KVM guest with PAE and with legacy paging. The existing PTI
>> code for x86-64 already prepares a lot of the stuff needed
>> for 32 bit too, thanks for that to all the people involved
>> in its development :)
> 
> Hi,
> 
> I've waited for this patches for a long time, until I've tried to
> exploit meltdown on some old 32-bit CPUs and failed. Pentium M
> seems to speculatively execute the second load with eax
> always equal to 0:
> 
> 	movzx (%[addr]), %%eax
> 	shl $12, %%eax
> 	movzx (%[target], %%eax), %%eax
> 
> And on Pentium 4-based Xeon the second load seems to be never executed,
> even without shift (shifts are slow on some or all Pentium 4's). Maybe
> not all P6 and Netbursts CPUs are affected, but I'm not sure. Maybe the
> kernel, at least on 32-bit, should try to exploit meltdown to test if
> the CPU is really affected.

The PoC apparently does not work with 3GB of memory or more on 32-bit. Does
you setup has more? Can you try the attack while setting max_addr=1G ?

Thanks,
Nadav

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
