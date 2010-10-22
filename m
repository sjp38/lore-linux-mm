Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D74FC6B004A
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 22:06:14 -0400 (EDT)
Received: from mail-iw0-f169.google.com (mail-iw0-f169.google.com [209.85.214.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id o9M25ftM020578
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 19:05:41 -0700
Received: by iwn9 with SMTP id 9so74712iwn.14
        for <linux-mm@kvack.org>; Thu, 21 Oct 2010 19:05:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201010220050.o9M0ognt032167@hera.kernel.org>
References: <201010220050.o9M0ognt032167@hera.kernel.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 21 Oct 2010 18:59:16 -0700
Message-ID: <AANLkTi=2tPU6qwuoOEfS7NfsNX+7vCYhvkHzNOcx4Gf3@mail.gmail.com>
Subject: Re: [GIT PULL] memblock for 2.6.37
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: "H. Peter Anvin" <hpa@linux.intel.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, CAI Qian <caiqian@redhat.com>, "David S. Miller" <davem@davemloft.net>, Felipe Balbi <balbi@ti.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Jan Beulich <jbeulich@novell.com>, Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Kevin Hilman <khilman@deeprootsystems.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Michael Ellerman <michael@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Paul Mundt <lethal@linux-sh.org>, Peter Zijlstra <peterz@infradead.org>, Russell King <linux@arm.linux.org.uk>, Russell King <rmk@arm.linux.org.uk>, Stephen Rothwell <sfr@canb.auug.org.au>, Thomas Gleixner <tglx@linutronix.de>, Tomi Valkeinen <tomi.valkeinen@nokia.com>, Vivek Goyal <vgoyal@redhat.com>, Yinghai Lu <yinghai@kernel.org>, ext Grazvydas Ignotas <notasas@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 21, 2010 at 5:50 PM, H. Peter Anvin <hpa@linux.intel.com> wrote=
:
>
> The unmerged branch is at:
>
> =A0git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip.git co=
re-memblock-for-linus
>
> The premerged branch is at:
>
> =A0git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip.git co=
re-memblock-for-linus-merged

I always tend to take the unmerged version, because I want to see what
the conflicts are (it gives me some view of what clashes), but when
people do pre-merges I then try to compare my merge against theirs.

However, in this case, your pre-merged version differs. But I think
it's your merge that was incorrect. You left this line:

   obj-$(CONFIG_HAVE_EARLY_RES) +=3D early_res.o

in kernel/Makefile, even though kernel/early_res.c is gone.

I'll push out my merge, but please do verify that it all looks ok.

                               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
