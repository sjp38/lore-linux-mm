Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 772166B0007
	for <linux-mm@kvack.org>; Sat, 10 Feb 2018 15:23:01 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id n130so2300281itg.1
        for <linux-mm@kvack.org>; Sat, 10 Feb 2018 12:23:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g1sor1299148itg.13.2018.02.10.12.23.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 10 Feb 2018 12:23:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180210091543.ynypx4y3koz44g7y@angband.pl>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <CALCETrUF61fqjXKG=kwf83JWpw=kgL16UvKowezDVwVA1=YVAw@mail.gmail.com>
 <20180209191112.55zyjf4njum75brd@suse.de> <20180210091543.ynypx4y3koz44g7y@angband.pl>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 10 Feb 2018 12:22:59 -0800
Message-ID: <CA+55aFwdLZjDcfhj4Ps=dUfd7ifkoYxW0FoH_JKjhXJYzxUSZQ@mail.gmail.com>
Subject: Re: [PATCH 00/31 v2] PTI support for x86_32
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Adam Borowski <kilobyte@angband.pl>
Cc: Joerg Roedel <jroedel@suse.de>, Andy Lutomirski <luto@kernel.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>

On Sat, Feb 10, 2018 at 1:15 AM, Adam Borowski <kilobyte@angband.pl> wrote:
>
> Alas, we got some data:
> https://popcon.debian.org/ says 20% of x86 users have i386 as their main ABI
> (current; people with popcon installed).

One of the issues I've seen is that people often simply move a disk
(or copy an installation) when upgrading machines.

Does Debian make it easy to upgrade to a 64-bit kernel if you have a
32-bit install? Because if not, then it's entirely possible that a lot
of people started out with a 32-bit install (maybe they even had a
64-bit kernel, but they started when the 32-bit install was the
default one), and never upgraded their kernel.

It really should be easy to _just_ upgrade the kernel. But if the
distro doesn't support it, most people won't do it.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
