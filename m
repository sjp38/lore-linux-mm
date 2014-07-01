Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8C6696B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 05:26:23 -0400 (EDT)
Received: by mail-ig0-f180.google.com with SMTP id h18so5229776igc.7
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 02:26:23 -0700 (PDT)
Received: from cam-admin0.cambridge.arm.com (cam-admin0.cambridge.arm.com. [217.140.96.50])
        by mx.google.com with ESMTP id fl10si26291771pab.132.2014.07.01.02.26.22
        for <linux-mm@kvack.org>;
        Tue, 01 Jul 2014 02:26:22 -0700 (PDT)
Date: Tue, 1 Jul 2014 10:23:46 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v2 09/10] arm64,ia64,ppc,s390,sh,tile,um,x86,mm: Remove
 default gate area
Message-ID: <20140701092345.GH28164@arm.com>
References: <cover.1404164803.git.luto@amacapital.net>
 <e1656ab2adfd1891f62610abe3e85ad992ee0cbf.1404164803.git.luto@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e1656ab2adfd1891f62610abe3e85ad992ee0cbf.1404164803.git.luto@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.org" <hpa@zytor.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Catalin Marinas <Catalin.Marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "linux390@de.ibm.com" <linux390@de.ibm.com>, Chris Metcalf <cmetcalf@tilera.com>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Nathan Lynch <Nathan_Lynch@mentor.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "user-mode-linux-devel@lists.sourceforge.net" <user-mode-linux-devel@lists.sourceforge.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Jun 30, 2014 at 10:53:20PM +0100, Andy Lutomirski wrote:
> The core mm code will provide a default gate area based on
> FIXADDR_USER_START and FIXADDR_USER_END if
> !defined(__HAVE_ARCH_GATE_AREA) && defined(AT_SYSINFO_EHDR).
> 
> This default is only useful for ia64.  arm64, ppc, s390, sh, tile,
> 64-bit UML, and x86_32 have their own code just to disable it.  arm,
> 32-bit UML, and x86_64 have gate areas, but they have their own
> implementations.
> 
> This gets rid of the default and moves the code into ia64.
> 
> This should save some code on architectures without a gate area: it's
> now possible to inline the gate_area functions in the default case.

For the arm64 bit:

  Acked-by: Will Deacon <will.deacon@arm.com>

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
