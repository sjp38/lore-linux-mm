Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 62E5D6B0069
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 05:33:35 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id y16so5175176wmd.6
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 02:33:35 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.24])
        by mx.google.com with ESMTPS id ue16si33377516wjb.138.2016.12.09.02.33.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Dec 2016 02:33:34 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC, PATCHv1 00/28] 5-level paging
Date: Fri, 09 Dec 2016 11:24:12 +0100
Message-ID: <13962749.Q2mLWEctkQ@wuerfel>
In-Reply-To: <20161209050130.GC2595@gmail.com>
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com> <20161209050130.GC2595@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, maxim.kuvyrkov@linaro.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, broonie@kernel.org, schwidefsky@de.ibm.com

On Friday, December 9, 2016 6:01:30 AM CET Ingo Molnar wrote:
> >   - Handle opt-in wider address space for userspace.
> > 
> >     Not all userspace is ready to handle addresses wider than current
> >     47-bits. At least some JIT compiler make use of upper bits to encode
> >     their info.
> > 
> >     We need to have an interface to opt-in wider addresses from userspace
> >     to avoid regressions.
> > 
> >     For now, I've included testing-only patch which bumps TASK_SIZE to
> >     56-bits. This can be handy for testing to see what breaks if we max-out
> >     size of virtual address space.
> 
> So this is just a detail - but it sounds a bit limiting to me to provide an 'opt 
> in' flag for something that will work just fine on the vast majority of 64-bit 
> software.
> 
> Please make this an opt out compatibility flag instead: similar to how we handle 
> address space layout limitations/quirks ABI details, such as ADDR_LIMIT_32BIT, 
> ADDR_LIMIT_3GB, ADDR_COMPAT_LAYOUT, READ_IMPLIES_EXEC, etc.

We've had a similar discussion about JIT software on ARM64, which has a wide
range of supported page table layouts and some software wants to limit that
to a specific number.

I don't remember the outcome of that discussion, but I'm adding a few people
to Cc that might remember.

There have also been some discussions in the past to make the depth of the
page table a per-task decision on s390, since you may have some tasks that
run just fine with two or three levels of paging while another task actually
wants the full 64-bit address space. I wonder how much extra work this would
be on top of the boot-time option.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
