Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id E6B836B0268
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 13:16:08 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 81so11967232iog.0
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 10:16:08 -0800 (PST)
Received: from mail-io0-x242.google.com (mail-io0-x242.google.com. [2607:f8b0:4001:c06::242])
        by mx.google.com with ESMTPS id h190si10047805ite.62.2016.12.08.10.16.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 10:16:08 -0800 (PST)
Received: by mail-io0-x242.google.com with SMTP id y124so1695398iof.1
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 10:16:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 8 Dec 2016 10:16:07 -0800
Message-ID: <CA+55aFz+-8RmOMqyqQOWSjJ82byy7BpJ791-gj=xO2rPKG6KFA@mail.gmail.com>
Subject: Re: [RFC, PATCHv1 00/28] 5-level paging
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Dec 8, 2016 at 8:21 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
>
> This patchset is still very early. There are a number of things missing
> that we have to do before asking anyone to merge it (listed below).
> It would be great if folks can start testing applications now (in QEMU) to
> look for breakage.
> Any early comments on the design or the patches would be appreciated as
> well.

Looks ok to me. Starting off with a compile-time config option seems fine.

I do think that the x86 cpuid part should (patch 15) should be the
first patch, so that we see "la57" as a capability in /proc/cpuinfo
whether it's being enabled or not? We should merge that part
regardless of any mm patches, I think.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
