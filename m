Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 820546B0038
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 03:34:43 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x124so2227978wmf.1
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 00:34:43 -0700 (PDT)
Received: from mail-wr0-x241.google.com (mail-wr0-x241.google.com. [2a00:1450:400c:c0c::241])
        by mx.google.com with ESMTPS id l2si9995077wrb.253.2017.03.17.00.34.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 00:34:42 -0700 (PDT)
Received: by mail-wr0-x241.google.com with SMTP id u48so8488721wrc.1
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 00:34:41 -0700 (PDT)
Date: Fri, 17 Mar 2017 08:34:37 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v7 1/3] x86/mm: Adapt MODULES_END based on Fixmap section
 size
Message-ID: <20170317073437.GA14797@gmail.com>
References: <20170314170508.100882-1-thgarnie@google.com>
 <20170316081013.GB7815@gmail.com>
 <CAJcbSZEB09inR2KLF_puOnmAK7QUv-zJHcguiF0qucUYTtg1Pw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJcbSZEB09inR2KLF_puOnmAK7QUv-zJHcguiF0qucUYTtg1Pw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Jonathan Corbet <corbet@lwn.net>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Kees Cook <keescook@chromium.org>, Juergen Gross <jgross@suse.com>, Andy Lutomirski <luto@kernel.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, Chris Wilson <chris@chris-wilson.co.uk>, Andy Lutomirski <luto@amacapital.net>, "Rafael J . Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>, Jiri Kosina <jikos@kernel.org>, Matt Fleming <matt@codeblueprint.co.uk>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Rusty Russell <rusty@rustcorp.com.au>, Paolo Bonzini <pbonzini@redhat.com>, Borislav Petkov <bp@suse.de>, Christian Borntraeger <borntraeger@de.ibm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Luis R . Rodriguez" <mcgrof@kernel.org>, Stanislaw Gruszka <sgruszka@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, Joerg Roedel <joro@8bytes.org>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, the arch/x86 maintainers <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, Linux PM list <linux-pm@vger.kernel.org>, linux-efi@vger.kernel.org, xen-devel@lists.xenproject.org, lguest@lists.ozlabs.org, kvm list <kvm@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>


* Thomas Garnier <thgarnie@google.com> wrote:

> On Thu, Mar 16, 2017 at 1:10 AM, Ingo Molnar <mingo@kernel.org> wrote:
> >
> > Note that asm/fixmap.h is an x86-ism that isn't present in many other
> > architectures, so this hunk will break the build.
> >
> > To make progress with these patches I've fixed it up with an ugly #ifdef
> > CONFIG_X86, but it needs a real solution instead before this can be pushed
> > upstream.
> 
> I also saw an error on x86 tip on special configuration. I found this
> new patch below to be a good solution to both.
> 
> Let me know what you think.
> 
> =====
> 
> This patch aligns MODULES_END to the beginning of the Fixmap section.
> It optimizes the space available for both sections. The address is
> pre-computed based on the number of pages required by the Fixmap
> section.
> 
> It will allow GDT remapping in the Fixmap section. The current
> MODULES_END static address does not provide enough space for the kernel
> to support a large number of processors.
> 
> Signed-off-by: Thomas Garnier <thgarnie@google.com>
> ---
> Based on next-20170308
> ---
>  Documentation/x86/x86_64/mm.txt         | 5 ++++-
>  arch/x86/include/asm/pgtable_64.h       | 1 +
>  arch/x86/include/asm/pgtable_64_types.h | 3 ++-
>  3 files changed, 7 insertions(+), 2 deletions(-)

The patch is heavily whitespace and line wrap damaged :-(

Please send a properly titled, changelogged delta patch against tip:master (or 
tip:x86/mm) to remove the CONFIG_X86 hack and fix the build bug.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
