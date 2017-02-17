Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id B9FCE6B0038
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 16:01:22 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id 45so41973918otd.6
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 13:01:22 -0800 (PST)
Received: from mail-oi0-x244.google.com (mail-oi0-x244.google.com. [2607:f8b0:4003:c06::244])
        by mx.google.com with ESMTPS id f24si1514040ote.213.2017.02.17.13.01.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 13:01:22 -0800 (PST)
Received: by mail-oi0-x244.google.com with SMTP id e123so110583oig.0
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 13:01:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALCETrW6YBxZw0NJGHe92dy7qfHqRHNr0VqTKV=O4j9r8hcSew@mail.gmail.com>
References: <20170217141328.164563-1-kirill.shutemov@linux.intel.com>
 <20170217141328.164563-34-kirill.shutemov@linux.intel.com>
 <CA+55aFwgbHxV-Ha2n1H=Z7P6bgcQ3D8aW=fr8ZrQ5OnvZ1vOYg@mail.gmail.com> <CALCETrW6YBxZw0NJGHe92dy7qfHqRHNr0VqTKV=O4j9r8hcSew@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 17 Feb 2017 13:01:21 -0800
Message-ID: <CA+55aFxu0p90nz6-VPFLCLBSpEVx7vNFGP_M8j=YS-Dk-zfJGg@mail.gmail.com>
Subject: Re: [PATCHv3 33/33] mm, x86: introduce PR_SET_MAX_VADDR and PR_GET_MAX_VADDR
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Linux API <linux-api@vger.kernel.org>

On Fri, Feb 17, 2017 at 12:12 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>
> At the very least, I'd want to see
> MAP_FIXED_BUT_DONT_BLOODY_UNMAP_ANYTHING.  I *hate* the current
> interface.

That's unrelated, but I guess w could add a MAP_NOUNMAP flag, and then
you can use MAP_FIXED | MAP_NOUNMAP or something.

But that has nothing to do with the 47-vs-56 bit issue.

> How about MAP_LIMIT where the address passed in is interpreted as an
> upper bound instead of a fixed address?

Again, that's a unrelated semantic issue. Right now - if you don't
pass in MAP_FIXED at all, the "addr" argument is used as a starting
value for deciding where to find an unmapped area. But there is no way
to specify the end. That would basically be what the process control
thing would be (not per-system-call, but per-thread ).

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
