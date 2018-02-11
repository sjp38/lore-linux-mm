Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8D1C76B0003
	for <linux-mm@kvack.org>; Sun, 11 Feb 2018 18:47:22 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id a2so6052065pgn.7
        for <linux-mm@kvack.org>; Sun, 11 Feb 2018 15:47:22 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id t7si676100pfh.290.2018.02.11.15.47.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 11 Feb 2018 15:47:21 -0800 (PST)
Message-ID: <1518392837.3979.14.camel@HansenPartnership.com>
Subject: Re: [PATCH 00/31 v2] PTI support for x86_32
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Sun, 11 Feb 2018 15:47:17 -0800
In-Reply-To: <F7FB13AC-EB26-48DE-BDB4-909D19DEAE7C@amacapital.net>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
	 <CALCETrUF61fqjXKG=kwf83JWpw=kgL16UvKowezDVwVA1=YVAw@mail.gmail.com>
	 <20180209191112.55zyjf4njum75brd@suse.de>
	 <20180210091543.ynypx4y3koz44g7y@angband.pl>
	 <CA+55aFwdLZjDcfhj4Ps=dUfd7ifkoYxW0FoH_JKjhXJYzxUSZQ@mail.gmail.com>
	 <20180211105909.53bv5q363u7jgrsc@angband.pl>
	 <6FB16384-7597-474E-91A1-1AF09201CEAC@gmail.com>
	 <0C6EFF56-F135-480C-867C-B117F114A99F@amacapital.net>
	 <1518387160.3979.10.camel@HansenPartnership.com>
	 <F7FB13AC-EB26-48DE-BDB4-909D19DEAE7C@amacapital.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Mark D Rustad <mrustad@gmail.com>, Adam Borowski <kilobyte@angband.pl>, Linus Torvalds <torvalds@linux-foundation.org>, Joerg Roedel <jroedel@suse.de>, Andy Lutomirski <luto@kernel.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>

On Sun, 2018-02-11 at 14:30 -0800, Andy Lutomirski wrote:
> 
> > 
> > On Feb 11, 2018, at 2:12 PM, James Bottomley <James.Bottomley@Hanse
> > nPartnership.com> wrote:
> > 
> > > 
> > > On Sun, 2018-02-11 at 11:42 -0800, Andy Lutomirski wrote:
> > > 
> > > > 
> > > > On Feb 11, 2018, at 9:40 AM, Mark D Rustad <mrustad@gmail.com>
> > > > wrote:
> > > > 
> > > > 
> > > > > 
> > > > > 
> > > > > On Feb 11, 2018, at 2:59 AM, Adam Borowski <kilobyte@angband.
> > > > > pl>
> > > > > wrote:
> > > > > 
> > > > > > 
> > > > > > 
> > > > > > Does Debian make it easy to upgrade to a 64-bit kernel if
> > > > > > you
> > > > > > have a
> > > > > > 32-bit install?
> > > > > 
> > > > > Quite easy, yeah.A A Crossgrading userspace is not for the
> > > > > faint of the heart, but changing just the kernel is fine.
> > > > 
> > > > ISTR that iscsi doesn't work when running a 64-bit kernel with
> > > > a 32-bit userspace. I remember someone offered kernel patches
> > > > to fix it, but I think they were rejected. I haven't messed
> > > > with that stuff in many years, so perhaps the userspace side
> > > > now has accommodation for it. It might be something to check
> > > > on.
> > > > 
> > > 
> > > At the risk of suggesting heresy, should we consider removing
> > > x86_32 support at some point?
> > 
> > Hey, my cloud server is 32 bit:
> > 
> > bedivere:~# cat /proc/cpuinfoA 
> > processorA A A A : 0
> > vendor_idA A A A : GenuineIntel
> > cpu familyA A A A : 15
> > modelA A A A A A A A : 2
> > model nameA A A A : Intel(R) Pentium(R) 4 CPU 2.80GHz
> > steppingA A A A : 9
> > microcodeA A A A : 0x2e
> > cpu MHzA A A A A A A A : 2813.464
> > [...]
> > 
> > I suspect a lot of people are in the same position: grandfathered
> > in on an old hosting plan, but not really willing to switch to a
> > new 64 bit box because the monthly cost about doubles and nothing
> > it does is currently anywhere up to (let alone over) the capacity
> > of the single 686 processor.
> > 
> > The thing which is making me consider it is actually getting a TPM
> > to protect the private keys, but doubling the monthly cost is still
> > a huge disincentive.
> 
> Where are they hosting this?A A Last I checked, replacing a P4 and
> motherboard with something new paid for itself in about a year in
> power savings.

It's a rented server not a co-lo cage. A I don't doubt it's costing the
hosting provider, but they're keeping my rates low.

James

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
