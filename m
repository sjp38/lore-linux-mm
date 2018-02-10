Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id E87456B0005
	for <linux-mm@kvack.org>; Sat, 10 Feb 2018 04:19:34 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id p64so2980290lfe.12
        for <linux-mm@kvack.org>; Sat, 10 Feb 2018 01:19:34 -0800 (PST)
Received: from tartarus.angband.pl (tartarus.angband.pl. [89.206.35.136])
        by mx.google.com with ESMTPS id l2si1470657ljb.252.2018.02.10.01.19.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 10 Feb 2018 01:19:33 -0800 (PST)
Date: Sat, 10 Feb 2018 10:15:44 +0100
From: Adam Borowski <kilobyte@angband.pl>
Subject: Re: [PATCH 00/31 v2] PTI support for x86_32
Message-ID: <20180210091543.ynypx4y3koz44g7y@angband.pl>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <CALCETrUF61fqjXKG=kwf83JWpw=kgL16UvKowezDVwVA1=YVAw@mail.gmail.com>
 <20180209191112.55zyjf4njum75brd@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180209191112.55zyjf4njum75brd@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <jroedel@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>

On Fri, Feb 09, 2018 at 08:11:12PM +0100, Joerg Roedel wrote:
> On Fri, Feb 09, 2018 at 05:47:43PM +0000, Andy Lutomirski wrote:
> > One thing worth noting is that performance of this whole series is
> > going to be abysmal due to the complete lack of 32-bit PCID.  Maybe
> > any kernel built with this option set that runs on a CPU that has the
> > PCID bit set in CPUID should print a big fat warning like "WARNING:
> > you are using 32-bit PTI on a 64-bit PCID-capable CPU.  Your
> > performance will increase dramatically if you switch to a 64-bit
> > kernel."
> 
> Thanks for your review. I can add this warning, but I just hope that not
> a lot of people will actually see it :)

Alas, we got some data:
https://popcon.debian.org/ says 20% of x86 users have i386 as their main ABI
(current; people with popcon installed).

Of those, 80% use 32-bit kernels: i686 881, x86_64 229, i586 14
(uname -m included in bug reports; data for 2016) -- and bug reporters tend
to have more clue than the average user.  There's no way so many folks still
use pre-2004 computers.

Thus, if you could include that big fat warning, distro developers would be
thankful.  Make it show fiery letters if you can.  Preferably, we'd want a
huge mallet reach out of the screen and bonk the user on the head, but with
that impossible, a scary message would help.

Let them use 32-bit userland, but if someone runs such a kernel on a modern
machine, some kind of verbal abuse is warranted.


Meow!
-- 
ac?aGBP'a  3/4 a >>ac?aGBP|a ? 
aGBP 3/4 a ?ac?a ?a ?aGBP?a!? Vat kind uf sufficiently advanced technology iz dis!?
ac?a!?a ?a .a ?a ?a ?                                 -- Genghis Ht'rok'din
a ?a 3aGBP?a ?a ?a ?a ? 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
