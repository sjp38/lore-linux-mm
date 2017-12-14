Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EF0066B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 16:28:21 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id t65so5722700pfe.22
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 13:28:21 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u4si3431711pgq.646.2017.12.14.13.28.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 13:28:20 -0800 (PST)
Received: from mail-it0-f53.google.com (mail-it0-f53.google.com [209.85.214.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 71D9B2190C
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 21:28:20 +0000 (UTC)
Received: by mail-it0-f53.google.com with SMTP id z6so14700465iti.4
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 13:28:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171214194334.GD3326@worktop>
References: <20171214112726.742649793@infradead.org> <20171214113851.398563731@infradead.org>
 <20171214194334.GD3326@worktop>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 14 Dec 2017 13:27:58 -0800
Message-ID: <CALCETrXroE4jv_gj0Jb8TVbcXoQP6PQ9yfydrBFR5QoYVXpFKQ@mail.gmail.com>
Subject: Re: [PATCH v2 06/17] x86/ldt: Do not install LDT for kernel threads
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Thu, Dec 14, 2017 at 11:43 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Thu, Dec 14, 2017 at 12:27:32PM +0100, Peter Zijlstra wrote:
>> From: Thomas Gleixner <tglx@linutronix.de>
>>
>> Kernel threads can use the mm of a user process temporarily via use_mm(),
>> but there is no point in installing the LDT which is associated to that mm
>> for the kernel thread.
>
> So thinking about this a bit more; I fear its not correct.
>
> Suppose a kthread does use_mm() and we then schedule to a task of that
> process, we'll not pass through switch_mm() and we'll not install the
> LDT and bad things happen.
>
> Or am I missing something?
>

Nah, you're probably right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
