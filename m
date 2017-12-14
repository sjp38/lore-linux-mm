Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0BB5E6B025F
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 11:22:44 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id k1so4504675pgq.2
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 08:22:44 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e91si3400790plb.28.2017.12.14.08.22.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 08:22:42 -0800 (PST)
Received: from mail-it0-f52.google.com (mail-it0-f52.google.com [209.85.214.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7A7E8218DC
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 16:22:42 +0000 (UTC)
Received: by mail-it0-f52.google.com with SMTP id d137so12354652itc.2
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 08:22:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171214113851.248131745@infradead.org>
References: <20171214112726.742649793@infradead.org> <20171214113851.248131745@infradead.org>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 14 Dec 2017 08:22:20 -0800
Message-ID: <CALCETrX-dN6TfixtrG9H9uF2rH8xpXp+LbmSrQEf9YF5zB1HWQ@mail.gmail.com>
Subject: Re: [PATCH v2 03/17] arch: Allow arch_dup_mmap() to fail
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Thu, Dec 14, 2017 at 3:27 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> From: Thomas Gleixner <tglx@linutronix.de>
>
> In order to sanitize the LDT initialization on x86 arch_dup_mmap() must be
> allowed to fail. Fix up all instances.

Reviewed-by: Andy Lutomirski <luto@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
