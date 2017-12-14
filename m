Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id DA5A16B0253
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 11:21:00 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id m17so4476236pgu.19
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 08:21:00 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j8si3335435plk.551.2017.12.14.08.20.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 08:20:59 -0800 (PST)
Received: from mail-it0-f51.google.com (mail-it0-f51.google.com [209.85.214.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 78992218D2
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 16:20:59 +0000 (UTC)
Received: by mail-it0-f51.google.com with SMTP id u62so12680601ita.2
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 08:20:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171214113851.647809433@infradead.org>
References: <20171214112726.742649793@infradead.org> <20171214113851.647809433@infradead.org>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 14 Dec 2017 08:20:37 -0800
Message-ID: <CALCETrW0=FnqZMU_MLebyy5m7jj=w=yHYx=u6vghFkdmG7vsww@mail.gmail.com>
Subject: Re: [PATCH v2 11/17] selftests/x86/ldt_gdt: Prepare for access bit forced
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Thu, Dec 14, 2017 at 3:27 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> From: Thomas Gleixner <tglx@linutronix.de>
>
> In order to make the LDT mapping RO the access bit needs to be forced by
> the kernel. Adjust the test case so it handles that gracefully.

If this turns out to need reverting because it breaks Wine or
something, we're really going to regret it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
