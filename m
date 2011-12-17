Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 3CFB76B004F
	for <linux-mm@kvack.org>; Sat, 17 Dec 2011 13:39:26 -0500 (EST)
Received: by wgbds13 with SMTP id ds13so6912179wgb.26
        for <linux-mm@kvack.org>; Sat, 17 Dec 2011 10:39:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAMzpN2inHxaSnaYaYXZ4Ya3rK+MWXqR6dN5NVNZy3=OvP04uQA@mail.gmail.com>
References: <201112172258.24221.nai.xia@gmail.com> <CAMzpN2inHxaSnaYaYXZ4Ya3rK+MWXqR6dN5NVNZy3=OvP04uQA@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 17 Dec 2011 10:39:03 -0800
Message-ID: <CA+55aFzyEgDUSaNVQ1Nw5SBNd36Cvb-KrVdc1MYj+oRJt8xWgg@mail.gmail.com>
Subject: Re: Question about missing "cld" in x86 string assembly code
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Gerst <brgerst@gmail.com>
Cc: nai.xia@gmail.com, Andi Kleen <ak@linux.intel.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, Dec 17, 2011 at 9:08 AM, Brian Gerst <brgerst@gmail.com> wrote:
>
> The i386 ELF ABI states "The direction flag must be set to the
> =91=91forward=92=92 (that is, zero) direction before entry and upon exit =
from
> a function." =A0Therefore it can be assumed to be clear, unless
> explicitly set.

The exception, of course, being bootup, fault and interrupt handlers,
and after we've called out to foreign code (ie BIOS).

So there *are* a few cld's sprinkled around, they are just fairly rare.

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
