Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 956F76B0266
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 13:00:31 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id z12so16250941pgv.6
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 10:00:31 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u16si11969385plq.173.2017.12.12.10.00.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Dec 2017 10:00:30 -0800 (PST)
Received: from mail-it0-f49.google.com (mail-it0-f49.google.com [209.85.214.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id DCCD2218C5
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 18:00:29 +0000 (UTC)
Received: by mail-it0-f49.google.com with SMTP id d137so385435itc.2
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 10:00:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171212173333.669577588@linutronix.de>
References: <20171212173221.496222173@linutronix.de> <20171212173333.669577588@linutronix.de>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 12 Dec 2017 10:00:08 -0800
Message-ID: <CALCETrXLeGGw+g7GiGDmReXgOxjB-cjmehdryOsFK4JB5BJAFQ@mail.gmail.com>
Subject: Re: [patch 05/16] mm: Allow special mappings with user access cleared
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Dec 12, 2017 at 9:32 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> From: Peter Zijstra <peterz@infradead.org>
>
> In order to create VMAs that are not accessible to userspace create a new
> VM_NOUSER flag. This can be used in conjunction with
> install_special_mapping() to inject 'kernel' data into the userspace map.
>
> Similar to how arch_vm_get_page_prot() allows adding _PAGE_flags to
> pgprot_t, introduce arch_vm_get_page_prot_excl() which masks
> _PAGE_flags from pgprot_t and use this to implement VM_NOUSER for x86.

How does this interact with get_user_pages(), etc?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
