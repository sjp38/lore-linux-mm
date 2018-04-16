Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 14FD76B0268
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:01:57 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id b9so13555905wrj.15
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 09:01:57 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id z7si297071edp.247.2018.04.16.09.01.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 09:01:54 -0700 (PDT)
Date: Mon, 16 Apr 2018 18:01:54 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 00/35 v5] PTI support for x32
Message-ID: <20180416160154.GE15462@8bytes.org>
References: <1523892323-14741-1-git-send-email-joro@8bytes.org>
 <CA+55aFwGTOgSonVquab63PZG5z_NfgVF2A08iHaNeeqY5pdfnA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwGTOgSonVquab63PZG5z_NfgVF2A08iHaNeeqY5pdfnA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>

Hi Linus,

On Mon, Apr 16, 2018 at 08:32:46AM -0700, Linus Torvalds wrote:
> Also, it would be nice to have performance numbers,

Here are some numbers I gathered for Ingo on v2 of the patch-set:

	https://marc.info/?l=linux-kernel&m=151844711432661&w=2

I don't think they significantly changed, but I can measure them again
if needed.

Besides those, what other numbers/tests are you interested in?

> and check that the global page issues are at least fixed on 32-bit
> too, since we screwed that up on x86-64 initially.
> 
> On x86-32, the global pages are likely a bigger deal since there's no PCID.

Okay, I verify if there are any global bits left in the page-tables.
According to the PTDUMP_X86 the cpu_entry_area is mapped with G=1 (which
should be fine?) and another 4M range in the kernel mapping. I need to
check what that is.

Thanks,

	Joerg


> 
>                   Linus
