Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 634EA6B0003
	for <linux-mm@kvack.org>; Sun, 11 Feb 2018 17:34:23 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id f3so1661232wmc.8
        for <linux-mm@kvack.org>; Sun, 11 Feb 2018 14:34:23 -0800 (PST)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id 61si5343045wrq.197.2018.02.11.14.34.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Feb 2018 14:34:22 -0800 (PST)
Date: Sun, 11 Feb 2018 23:34:18 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 00/31 v2] PTI support for x86_32
Message-ID: <20180211223416.GA3762@localhost>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <CALCETrUF61fqjXKG=kwf83JWpw=kgL16UvKowezDVwVA1=YVAw@mail.gmail.com>
 <20180209191112.55zyjf4njum75brd@suse.de>
 <20180210091543.ynypx4y3koz44g7y@angband.pl>
 <CA+55aFwdLZjDcfhj4Ps=dUfd7ifkoYxW0FoH_JKjhXJYzxUSZQ@mail.gmail.com>
 <20180211105909.53bv5q363u7jgrsc@angband.pl>
 <6FB16384-7597-474E-91A1-1AF09201CEAC@gmail.com>
 <0C6EFF56-F135-480C-867C-B117F114A99F@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <0C6EFF56-F135-480C-867C-B117F114A99F@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Mark D Rustad <mrustad@gmail.com>, Adam Borowski <kilobyte@angband.pl>, Linus Torvalds <torvalds@linux-foundation.org>, Joerg Roedel <jroedel@suse.de>, Andy Lutomirski <luto@kernel.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>

On Sun 2018-02-11 11:42:47, Andy Lutomirski wrote:
>=20
>=20
> On Feb 11, 2018, at 9:40 AM, Mark D Rustad <mrustad@gmail.com> wrote:
>=20
> >> On Feb 11, 2018, at 2:59 AM, Adam Borowski <kilobyte@angband.pl> wrote:
> >>=20
> >>> Does Debian make it easy to upgrade to a 64-bit kernel if you have a
> >>> 32-bit install?
> >>=20
> >> Quite easy, yeah.  Crossgrading userspace is not for the faint of the =
heart,
> >> but changing just the kernel is fine.
> >=20
> > ISTR that iscsi doesn't work when running a 64-bit kernel with a 32-bit=
 userspace. I remember someone offered kernel patches to fix it, but I thin=
k they were rejected. I haven't messed with that stuff in many years, so pe=
rhaps the userspace side now has accommodation for it. It might be somethin=
g to check on.
> >=20

It might make sense to retry those patches... if we want people to
move to 64bit kernels, it makes sense to provide complete emulation
for 32bit distros...

> At the risk of suggesting heresy, should we consider removing x86_32
> support at some point?

Heresy!

We still support 486s. I don't know if anyone really uses them, but
T40p is an acceptable machine to ssh from. X60 is still the machine I
prefer for traveling. Fast enough if you don't compile, and nicer
keyboard/screen than X220...

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
