Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8AADE6B0035
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 06:20:31 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id k14so3349603wgh.32
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 03:20:30 -0700 (PDT)
Received: from radon.swed.at (a.ns.miles-group.at. [95.130.255.143])
        by mx.google.com with ESMTPS id gp3si2668575wib.52.2014.07.18.03.20.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Jul 2014 03:20:27 -0700 (PDT)
Message-ID: <53C8F4DF.8020103@nod.at>
Date: Fri, 18 Jul 2014 12:20:15 +0200
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: [PATCH v3] arm64,ia64,ppc,s390,sh,tile,um,x86,mm: Remove default
 gate area
References: <70f331f59e620dc4e66bd3fa095e6f6b744b532b.1405281639.git.luto@amacapital.net> <CALCETrXG6nL4K=Er+kv5-CXBDVa0TLg9yR6iePnMyE2ufXgKkw@mail.gmail.com> <20140718101416.GB1818@arm.com>
In-Reply-To: <20140718101416.GB1818@arm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@amacapital.net>
Cc: Catalin Marinas <Catalin.Marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "linux390@de.ibm.com" <linux390@de.ibm.com>, Chris Metcalf <cmetcalf@tilera.com>, Jeff Dike <jdike@addtoit.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Nathan Lynch <Nathan_Lynch@mentor.com>, X86 ML <x86@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "user-mode-linux-devel@lists.sourceforge.net" <user-mode-linux-devel@lists.sourceforge.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Am 18.07.2014 12:14, schrieb Will Deacon:
> On Tue, Jul 15, 2014 at 03:47:26PM +0100, Andy Lutomirski wrote:
>> On Sun, Jul 13, 2014 at 1:01 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>>> The core mm code will provide a default gate area based on
>>> FIXADDR_USER_START and FIXADDR_USER_END if
>>> !defined(__HAVE_ARCH_GATE_AREA) && defined(AT_SYSINFO_EHDR).
>>>
>>> This default is only useful for ia64.  arm64, ppc, s390, sh, tile,
>>> 64-bit UML, and x86_32 have their own code just to disable it.  arm,
>>> 32-bit UML, and x86_64 have gate areas, but they have their own
>>> implementations.
>>>
>>> This gets rid of the default and moves the code into ia64.
>>>
>>> This should save some code on architectures without a gate area: it's
>>> now possible to inline the gate_area functions in the default case.
>>
>> Can one of you pull this somewhere?  Otherwise I can put it somewhere
>> stable and ask for -next inclusion, but that seems like overkill for a
>> single patch.

For the um bits:
Acked-by: Richard Weinberger <richard@nod.at>

> I'd be happy to take the arm64 part, but it doesn't feel right for mm/*
> changes (or changes to other archs) to go via our tree.
> 
> I'm not sure what the best approach is if you want to send this via a single
> tree. Maybe you could ask akpm nicely?

Going though Andrew's tree sounds sane to me.

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
