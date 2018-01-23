Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4452F800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 13:14:05 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id f67so1530646itf.2
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 10:14:05 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id t73si15732969ioi.54.2018.01.23.10.14.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 10:14:04 -0800 (PST)
Date: Tue, 23 Jan 2018 10:13:35 -0800
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCHv6, RESEND 4/4] x86/boot/compressed/64: Handle 5-level
 paging boot if kernel is above 4G
Message-ID: <20180123181335.GP7844@tassilo.jf.intel.com>
References: <20180123170913.41791-1-kirill.shutemov@linux.intel.com>
 <20180123170913.41791-5-kirill.shutemov@linux.intel.com>
 <CA+55aFxgsZCqJdhZJ3ztyTTFPPgkn_aH6d4ziW1g0YJKc++0+A@mail.gmail.com>
 <20180123173703.rrr7igl7xtlsawhf@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180123173703.rrr7igl7xtlsawhf@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Jan 23, 2018 at 08:37:03PM +0300, Kirill A. Shutemov wrote:
> On Tue, Jan 23, 2018 at 09:31:16AM -0800, Linus Torvalds wrote:
> > On Tue, Jan 23, 2018 at 9:09 AM, Kirill A. Shutemov
> > <kirill.shutemov@linux.intel.com> wrote:
> > >
> > > But if the bootloader put the kernel above 4G (not sure if anybody does
> > > this), we would lose control as soon as paging is disabled, because the
> > > code becomes unreachable to the CPU.
> > 
> > I do wonder if we need this. Why would a bootloader ever put the data
> > above 4G? Does this really happen?  Wouldn't it be easier to just say
> > "bootloaders better put the kernel in the low 4G"?
> 
> I don't know much about bootloaders, but do we even have such guarantee
> for in-kernel bootloader -- kexec?

There's no such guarantee, so we need it at least for kexec.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
