Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2856C6B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 09:20:03 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id n3so60353702wjy.6
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 06:20:03 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id n13si77852581wmg.164.2017.01.04.06.20.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 06:20:01 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id m203so91684755wma.3
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 06:20:01 -0800 (PST)
Date: Wed, 4 Jan 2017 17:19:59 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC, PATCHv2 29/29] mm, x86: introduce RLIMIT_VADDR
Message-ID: <20170104141959.GC17319@node.shutemov.name>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
 <20161227015413.187403-30-kirill.shutemov@linux.intel.com>
 <2736959.3MfCab47fD@wuerfel>
 <CALCETrV_qejd-Ozqo4vTqz=LuukMUPeQ7EVUQbfTxs_xNbO3oQ@mail.gmail.com>
 <20170103160457.GB17319@node.shutemov.name>
 <CALCETrW3=SsQeC-gWOVqwTtg022+gHei=xfUc2ei3kkX0CACpg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrW3=SsQeC-gWOVqwTtg022+gHei=xfUc2ei3kkX0CACpg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>

On Tue, Jan 03, 2017 at 10:27:22AM -0800, Andy Lutomirski wrote:
> On Tue, Jan 3, 2017 at 8:04 AM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > And what about stack? I'm not sure that everybody would be happy with
> > stack in the middle of address space.
> 
> I would, personally.  I think that, for very large address spaces, we
> should allocate a large block of stack and get rid of the "stack grows
> down forever" legacy idea.  Then we would never need to worry about
> the stack eventually hitting some other allocation.  And 2^57 bytes is
> hilariously large for a default stack.

The stack in the middle of address space can prevent creating other huuuge
contiguous mapping. Databases may want this.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
