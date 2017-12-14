Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E60B46B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 11:20:00 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id m9so5098761pff.0
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 08:20:00 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x12si3094369pgq.307.2017.12.14.08.19.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 08:19:59 -0800 (PST)
Received: from mail-it0-f53.google.com (mail-it0-f53.google.com [209.85.214.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id AAD0B2190A
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 16:19:58 +0000 (UTC)
Received: by mail-it0-f53.google.com with SMTP id d16so12368658itj.1
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 08:19:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171214113851.197682513@infradead.org>
References: <20171214112726.742649793@infradead.org> <20171214113851.197682513@infradead.org>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 14 Dec 2017 08:19:36 -0800
Message-ID: <CALCETrXzaa8svjHdm3G3=FKvAZoQx-CboE6YecdPsva+Lf_bJg@mail.gmail.com>
Subject: Re: [PATCH v2 02/17] mm: Exempt special mappings from mlock(),
 mprotect() and madvise()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Thu, Dec 14, 2017 at 3:27 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> It makes no sense to ever prod at special mappings with any of these
> syscalls.
>
> XXX should we include munmap() ?

This is an ABI break for the vdso.  Maybe that's okay, but mremap() on
the vdso is certainly used, and I can imagine debuggers using
mprotect().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
