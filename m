Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 8DCA86B0036
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 22:19:22 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so10737523pdj.26
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 19:19:22 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id ow8si9835380pdb.76.2014.07.28.19.19.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jul 2014 19:19:20 -0700 (PDT)
Message-ID: <1406600356.11977.4.camel@concordia>
Subject: Re: [PATCH v4] arm64, ia64, ppc, s390, sh, tile, um, x86, mm:
 Remove default gate area
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Tue, 29 Jul 2014 12:19:16 +1000
In-Reply-To: <6435254cc74d6e9172931f27be3854d522ad299b.1406232860.git.luto@amacapital.net>
References: 
	<6435254cc74d6e9172931f27be3854d522ad299b.1406232860.git.luto@amacapital.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Richard Weinberger <richard@nod.at>, x86@kernel.org, Ingo Molnar <mingo@redhat.com>, Fenghua Yu <fenghua.yu@intel.com>, user-mode-linux-devel@lists.sourceforge.net, Will Deacon <will.deacon@arm.com>, Jeff Dike <jdike@addtoit.com>, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, Tony Luck <tony.luck@intel.com>, Nathan Lynch <Nathan_Lynch@mentor.com>, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux390@de.ibm.com, linuxppc-dev@lists.ozlabs.org

On Thu, 2014-07-24 at 13:56 -0700, Andy Lutomirski wrote:
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

Looks good to me. Booted and everything seems happy, I still have a vdso etc.

Tested-by: Michael Ellerman <mpe@ellerman.id.au> (for powerpc)

cheers


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
