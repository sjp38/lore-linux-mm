Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id ECCF96B000D
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 13:45:16 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g7-v6so10254777wrb.19
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 10:45:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x40si4922425edx.299.2018.04.23.10.45.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Apr 2018 10:45:14 -0700 (PDT)
Date: Mon, 23 Apr 2018 19:45:06 +0200
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: [PATCH 00/37 v6] PTI support for x86-32
Message-ID: <20180423174506.mpbpnvfzv6fmpbzy@suse.de>
References: <1524498460-25530-1-git-send-email-joro@8bytes.org>
 <CA+55aFwg75rOXN5Q0qHf_GF-hnVo8mjxnTo2FbM993fuc8x7Gw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwg75rOXN5Q0qHf_GF-hnVo8mjxnTo2FbM993fuc8x7Gw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>

On Mon, Apr 23, 2018 at 09:45:38AM -0700, Linus Torvalds wrote:
> Just one question: have you checked the page table setup for the
> basics wrt the USER bit in particular?

Just checked that and there are no pages with GLB and USR set, not even
a vdso page.

> No global pages should be marked PAGE_USER, with the possible
> exception of that nasty old vsyscall page.

The vsyscall page does not exist on plain 32 bit, no? All I could find
there is the vdso page, and that has no compat mapping anymore in recent
upstream kernels. To my understanding the vdso page is mapped into the
user-space portion of the address space. At least that is what I found
while looking at this, but I might have missed something.

I actually ran into a vdso issue when porting these changes to 3.0
(where there still is a compat vdso mapping in the fixmap) so I checked
my upstream code too, but didn't find the code to setup a vdso in the
fixmap.

> And it would be nice to verify that the page tables for kernel
> mappings also don't have PAGE_USER on them, although again that
> vsyscall page can cause problems.

Checked that too, all USR mappings are below PAGE_OFFSET.


Regards,

	Joerg
