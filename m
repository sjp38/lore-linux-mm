Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 644536B0007
	for <linux-mm@kvack.org>; Sun, 11 Feb 2018 14:53:22 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q13so5830050pgt.17
        for <linux-mm@kvack.org>; Sun, 11 Feb 2018 11:53:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r29sor992794pfb.137.2018.02.11.11.53.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 11 Feb 2018 11:53:21 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
From: Andy Lutomirski <luto@amacapital.net>
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 00/31 v2] PTI support for x86_32
Date: Sun, 11 Feb 2018 11:42:47 -0800
Message-Id: <0C6EFF56-F135-480C-867C-B117F114A99F@amacapital.net>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org> <CALCETrUF61fqjXKG=kwf83JWpw=kgL16UvKowezDVwVA1=YVAw@mail.gmail.com> <20180209191112.55zyjf4njum75brd@suse.de> <20180210091543.ynypx4y3koz44g7y@angband.pl> <CA+55aFwdLZjDcfhj4Ps=dUfd7ifkoYxW0FoH_JKjhXJYzxUSZQ@mail.gmail.com> <20180211105909.53bv5q363u7jgrsc@angband.pl> <6FB16384-7597-474E-91A1-1AF09201CEAC@gmail.com>
In-Reply-To: <6FB16384-7597-474E-91A1-1AF09201CEAC@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark D Rustad <mrustad@gmail.com>
Cc: Adam Borowski <kilobyte@angband.pl>, Linus Torvalds <torvalds@linux-foundation.org>, Joerg Roedel <jroedel@suse.de>, Andy Lutomirski <luto@kernel.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>



On Feb 11, 2018, at 9:40 AM, Mark D Rustad <mrustad@gmail.com> wrote:

>> On Feb 11, 2018, at 2:59 AM, Adam Borowski <kilobyte@angband.pl> wrote:
>>=20
>>> Does Debian make it easy to upgrade to a 64-bit kernel if you have a
>>> 32-bit install?
>>=20
>> Quite easy, yeah.  Crossgrading userspace is not for the faint of the hea=
rt,
>> but changing just the kernel is fine.
>=20
> ISTR that iscsi doesn't work when running a 64-bit kernel with a 32-bit us=
erspace. I remember someone offered kernel patches to fix it, but I think th=
ey were rejected. I haven't messed with that stuff in many years, so perhaps=
 the userspace side now has accommodation for it. It might be something to c=
heck on.
>=20

At the risk of suggesting heresy, should we consider removing x86_32 support=
 at some point?=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
