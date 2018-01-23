Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 630A9800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 12:37:07 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id y18so661757wrh.12
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 09:37:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p23sor6359748edm.20.2018.01.23.09.37.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jan 2018 09:37:05 -0800 (PST)
Date: Tue, 23 Jan 2018 20:37:03 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv6, RESEND 4/4] x86/boot/compressed/64: Handle 5-level
 paging boot if kernel is above 4G
Message-ID: <20180123173703.rrr7igl7xtlsawhf@node.shutemov.name>
References: <20180123170913.41791-1-kirill.shutemov@linux.intel.com>
 <20180123170913.41791-5-kirill.shutemov@linux.intel.com>
 <CA+55aFxgsZCqJdhZJ3ztyTTFPPgkn_aH6d4ziW1g0YJKc++0+A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxgsZCqJdhZJ3ztyTTFPPgkn_aH6d4ziW1g0YJKc++0+A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Jan 23, 2018 at 09:31:16AM -0800, Linus Torvalds wrote:
> On Tue, Jan 23, 2018 at 9:09 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> >
> > But if the bootloader put the kernel above 4G (not sure if anybody does
> > this), we would lose control as soon as paging is disabled, because the
> > code becomes unreachable to the CPU.
> 
> I do wonder if we need this. Why would a bootloader ever put the data
> above 4G? Does this really happen?  Wouldn't it be easier to just say
> "bootloaders better put the kernel in the low 4G"?

I don't know much about bootloaders, but do we even have such guarantee
for in-kernel bootloader -- kexec?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
