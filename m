Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2ACBF6B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 07:06:10 -0500 (EST)
Received: by iouu10 with SMTP id u10so52222129iou.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 04:06:10 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 69si20879128iod.65.2015.11.25.04.06.09
        for <linux-mm@kvack.org>;
        Wed, 25 Nov 2015 04:06:09 -0800 (PST)
Date: Wed, 25 Nov 2015 12:06:01 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v3 3/4] arm64: mm: support ARCH_MMAP_RND_BITS.
Message-ID: <20151125120601.GC3109@e104818-lin.cambridge.arm.com>
References: <1447888808-31571-1-git-send-email-dcashman@android.com>
 <1447888808-31571-2-git-send-email-dcashman@android.com>
 <1447888808-31571-3-git-send-email-dcashman@android.com>
 <1447888808-31571-4-git-send-email-dcashman@android.com>
 <20151123150459.GD4236@arm.com>
 <56536114.1020305@android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56536114.1020305@android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Cashman <dcashman@android.com>
Cc: Will Deacon <will.deacon@arm.com>, dcashman@google.com, linux-doc@vger.kernel.org, linux-mm@kvack.org, hpa@zytor.com, mingo@kernel.org, aarcange@redhat.com, linux@arm.linux.org.uk, corbet@lwn.net, xypron.glpk@gmx.de, x86@kernel.org, hecmargi@upv.es, mgorman@suse.de, rientjes@google.com, bp@suse.de, nnk@google.com, dzickus@redhat.com, keescook@chromium.org, jpoimboe@redhat.com, tglx@linutronix.de, n-horiguchi@ah.jp.nec.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, salyzyn@android.com, ebiederm@xmission.com, jeffv@google.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com

On Mon, Nov 23, 2015 at 10:55:16AM -0800, Daniel Cashman wrote:
> On 11/23/2015 07:04 AM, Will Deacon wrote:
> > On Wed, Nov 18, 2015 at 03:20:07PM -0800, Daniel Cashman wrote:
> >> +config ARCH_MMAP_RND_BITS_MAX
> >> +       default 20 if ARM64_64K_PAGES && ARCH_VA_BITS=39

Where is ARCH_VA_BITS defined? We only have options like
ARM64_VA_BITS_39.

BTW, we no longer allow the 64K pages and 39-bit VA combination.

> >> +       default 24 if ARCH_VA_BITS=39
> >> +       default 23 if ARM64_64K_PAGES && ARCH_VA_BITS=42
> >> +       default 27 if ARCH_VA_BITS=42
> >> +       default 29 if ARM64_64K_PAGES && ARCH_VA_BITS=48
> >> +       default 33 if ARCH_VA_BITS=48
> >> +       default 15 if ARM64_64K_PAGES
> >> +       default 19
> >> +
> >> +config ARCH_MMAP_RND_COMPAT_BITS_MIN
> >> +       default 7 if ARM64_64K_PAGES
> >> +       default 11
> > 
> > FYI: we now support 16k pages too, so this might need updating. It would
> > be much nicer if this was somehow computed rather than have the results
> > all open-coded like this.
> 
> Yes, I ideally wanted this to be calculated based on the different page
> options and VA_BITS (which itself has a similar stanza), but I don't
> know how to do that/if it is currently supported in Kconfig. This would
> be even more desirable with the addition of 16K_PAGES, as with this
> setup we have a combinatorial problem.

For KASan, we ended up calculating KASAN_SHADOW_OFFSET in
arch/arm64/Makefile. What would the formula be for the above
ARCH_MMAP_RND_BITS_MAX?

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
