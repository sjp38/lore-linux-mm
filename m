Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3410C6B0006
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 05:16:29 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id k14so8626689wrc.14
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 02:16:29 -0800 (PST)
Received: from mail.alarsen.net (joe.alarsen.net. [2a01:4f8:191:10e8:1::fe])
        by mx.google.com with ESMTPS id i8si3320448wma.61.2018.02.12.02.16.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Feb 2018 02:16:27 -0800 (PST)
From: Anders Larsen <al@alarsen.net>
Subject: Re: [PATCH 00/31 v2] PTI support for x86_32
Date: Mon, 12 Feb 2018 11:16:24 +0100
Message-ID: <4155513.GHlSKmbAgC@alarsen-lx>
In-Reply-To: <20180211232556.1fdde355@alans-desktop>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org> <0C6EFF56-F135-480C-867C-B117F114A99F@amacapital.net> <20180211232556.1fdde355@alans-desktop>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Cox <gnomes@lxorguk.ukuu.org.uk>
Cc: Andy Lutomirski <luto@amacapital.net>, Mark D Rustad <mrustad@gmail.com>, Adam Borowski <kilobyte@angband.pl>, Linus Torvalds <torvalds@linux-foundation.org>, Joerg Roedel <jroedel@suse.de>, Andy Lutomirski <luto@kernel.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <"dani el.gruss"@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>

On Sunday, 11 February 2018 23:25 Alan Cox wrote:
> On Sun, 11 Feb 2018 11:42:47 -0800
> 
> Andy Lutomirski <luto@amacapital.net> wrote:
> > On Feb 11, 2018, at 9:40 AM, Mark D Rustad <mrustad@gmail.com> wrote:
> > >> On Feb 11, 2018, at 2:59 AM, Adam Borowski <kilobyte@angband.pl> wrote:
> > >>> Does Debian make it easy to upgrade to a 64-bit kernel if you have a
> > >>> 32-bit install?
> > >> 
> > >> Quite easy, yeah.  Crossgrading userspace is not for the faint of the
> > >> heart, but changing just the kernel is fine.
> > > 
> > > ISTR that iscsi doesn't work when running a 64-bit kernel with a 32-bit
> > > userspace. I remember someone offered kernel patches to fix it, but I
> > > think they were rejected. I haven't messed with that stuff in many
> > > years, so perhaps the userspace side now has accommodation for it. It
> > > might be something to check on.
> > > 
> > At the risk of suggesting heresy, should we consider removing x86_32
> > support at some point?
> 
> Probably - although it's still relevant for Quark. I can't think of any
> other in-production 32bit only processor at this point. Big core Intel
> went 64bit 2006 or so, atoms mostly 2008 or so (with some stragglers that
> are 32 or 64 bit depending if it's enabled) until 2011 (Cedartrail)

FWIW the Atom E6xx series (Tunnel Creek) is 32bit only and still in
production; my employer is using those beasts in several devices - and I'm
fighting an uphill battle to have those products ship with a recent kernel
(for certain values of recent)

> If someone stuck a fork in it just after the next long term kernel
> release then by the time that expired it would probably be historical
> interest only.
> 
> Does it not depend if there is someone crazy enough to maintain it
> however - 68000 is doing fine 8)

Cheers
Anders

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
