Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2697B6B0009
	for <linux-mm@kvack.org>; Sun, 11 Feb 2018 06:02:38 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id r13so3511963lff.22
        for <linux-mm@kvack.org>; Sun, 11 Feb 2018 03:02:38 -0800 (PST)
Received: from tartarus.angband.pl ([2a03:9300:10::8])
        by mx.google.com with ESMTPS id v2si2159927ljv.320.2018.02.11.03.02.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 11 Feb 2018 03:02:36 -0800 (PST)
Date: Sun, 11 Feb 2018 11:59:09 +0100
From: Adam Borowski <kilobyte@angband.pl>
Subject: Re: [PATCH 00/31 v2] PTI support for x86_32
Message-ID: <20180211105909.53bv5q363u7jgrsc@angband.pl>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <CALCETrUF61fqjXKG=kwf83JWpw=kgL16UvKowezDVwVA1=YVAw@mail.gmail.com>
 <20180209191112.55zyjf4njum75brd@suse.de>
 <20180210091543.ynypx4y3koz44g7y@angband.pl>
 <CA+55aFwdLZjDcfhj4Ps=dUfd7ifkoYxW0FoH_JKjhXJYzxUSZQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CA+55aFwdLZjDcfhj4Ps=dUfd7ifkoYxW0FoH_JKjhXJYzxUSZQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Joerg Roedel <jroedel@suse.de>, Andy Lutomirski <luto@kernel.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>

On Sat, Feb 10, 2018 at 12:22:59PM -0800, Linus Torvalds wrote:
> On Sat, Feb 10, 2018 at 1:15 AM, Adam Borowski <kilobyte@angband.pl> wrote:
> >
> > Alas, we got some data:
> > https://popcon.debian.org/ says 20% of x86 users have i386 as their main ABI
> > (current; people with popcon installed).
> 
> One of the issues I've seen is that people often simply move a disk
> (or copy an installation) when upgrading machines.

Less skilled users (ie, most of them) had until recently a different hurdle:
the "32-bit" option was shown way too prominently, without an explanation.

> Does Debian make it easy to upgrade to a 64-bit kernel if you have a
> 32-bit install?

Quite easy, yeah.  Crossgrading userspace is not for the faint of the heart,
but changing just the kernel is fine.

> Because if not, then it's entirely possible that a lot
> of people started out with a 32-bit install (maybe they even had a
> 64-bit kernel, but they started when the 32-bit install was the
> default one), and never upgraded their kernel.
> 
> It really should be easy to _just_ upgrade the kernel. But if the
> distro doesn't support it, most people won't do it.

I just realized that, for people who use distro kernels, the right way is a
message during upgrade.  Ie, it's up to the packagers rather than you.

Having a dire-sounding printk, though, would still be nice.


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
