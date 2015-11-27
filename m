Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8B5F46B0255
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 04:32:59 -0500 (EST)
Received: by padhx2 with SMTP id hx2so110371934pad.1
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 01:32:59 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v18si2343816pfi.251.2015.11.27.01.32.58
        for <linux-mm@kvack.org>;
        Fri, 27 Nov 2015 01:32:58 -0800 (PST)
Date: Fri, 27 Nov 2015 09:32:50 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v3 3/4] arm64: mm: support ARCH_MMAP_RND_BITS.
Message-ID: <20151127093249.GW3109@e104818-lin.cambridge.arm.com>
References: <1447888808-31571-1-git-send-email-dcashman@android.com>
 <1447888808-31571-2-git-send-email-dcashman@android.com>
 <1447888808-31571-3-git-send-email-dcashman@android.com>
 <1447888808-31571-4-git-send-email-dcashman@android.com>
 <20151123150459.GD4236@arm.com>
 <56536114.1020305@android.com>
 <20151125120601.GC3109@e104818-lin.cambridge.arm.com>
 <56561C71.30602@android.com>
 <CAPAsAGyJr5OD+_4TO9dt2EwOGUGewEy4bAmhFhDbP3RJ+6QxaA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPAsAGyJr5OD+_4TO9dt2EwOGUGewEy4bAmhFhDbP3RJ+6QxaA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Daniel Cashman <dcashman@android.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, mingo <mingo@kernel.org>, aarcange@redhat.com, Russell King <linux@arm.linux.org.uk>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, xypron.glpk@gmx.de, "x86@kernel.org" <x86@kernel.org>, hecmargi@upv.es, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Borislav Petkov <bp@suse.de>, nnk@google.com, dzickus@redhat.com, Kees Cook <keescook@chromium.org>, jpoimboe@redhat.com, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, salyzyn@android.com, "Eric W. Biederman" <ebiederm@xmission.com>, jeffv@google.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, dcashman@google.com

On Fri, Nov 27, 2015 at 11:36:30AM +0300, Andrey Ryabinin wrote:
> 2015-11-25 23:39 GMT+03:00 Daniel Cashman <dcashman@android.com>:
> > On 11/25/2015 04:06 AM, Catalin Marinas wrote:
> >> For KASan, we ended up calculating KASAN_SHADOW_OFFSET in
> >> arch/arm64/Makefile. What would the formula be for the above
> >> ARCH_MMAP_RND_BITS_MAX?
> >
> > The general formula I used ended up being:
> > _max = floor(log(TASK_SIZE)) - log(PAGE_SIZE) - 3
> 
> For kasan, we calculate KASAN_SHADOW_OFFSET in Makefile, because we need to use
> that value in Makefiles.
> 
> For ARCH_MMAP_RND_COMPAT_BITS_MIN/MAX I don't see a reason why it has
> to be in Kconfig.
> Can't we just use your formula to #define ARCH_MMAP_RND_COMPAT_BITS_*
> in some arch header?

Because there is another option, ARCH_MMAP_RND_BITS depending on EXPERT
which uses the MIN/MAX range defined per architecture. Since it's an
expert feature, we could as well ignore the MIN/MAX in Kconfig and just
add BUILD_BUG_ON checks to the code. This way we could simply define
them in C files.

Alternatively, add arithmetics support to kbuild ;).

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
