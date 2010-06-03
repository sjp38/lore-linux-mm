Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2EC836B01B5
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 09:41:35 -0400 (EDT)
Date: Thu, 3 Jun 2010 08:34:20 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Possible bug in 2.6.34 slub
In-Reply-To: <AANLkTinxOJShwd7xUornVI89BmJnbX9-a7LVWaciNdr5@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1006030833070.24954@router.home>
References: <AANLkTimEFy6VM3InWlqhVooQjKGSD3yBxlgeRbQC2r1L@mail.gmail.com> <20100531165528.35a323fb.rdunlap@xenotime.net> <4C047CF9.9000804@tmr.com> <AANLkTilLq-hn59CBcLnOsnT37ZizQR6MrZX6btKPhfpb@mail.gmail.com> <20100601123959.747228c6.rdunlap@xenotime.net>
 <alpine.DEB.2.00.1006011445100.9438@router.home> <AANLkTinxOJShwd7xUornVI89BmJnbX9-a7LVWaciNdr5@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Randy Dunlap <rdunlap@xenotime.net>, Giangiacomo Mariotti <gg.mariotti@gmail.com>, Bill Davidsen <davidsen@tmr.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86 maintainers <x86@kernel.org>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jun 2010, Pekka Enberg wrote:

> On Tue, Jun 1, 2010 at 10:48 PM, Christoph Lameter
> <cl@linux-foundation.org> wrote:
> > On Tue, 1 Jun 2010, Randy Dunlap wrote:
> >
> >> > >>> My cpu is an I7 920, so it has 4 cores and there's hyperthreading
> >> > >>> enabled, so there are 8 logical cpus. Is this a bug?
> >
> > Yes its a bug in the arch code or BIOS. The system configuration tells us
> > that there are more possible cpus and therefore the system prepares for
> > the additional cpus to be activated at some later time.
>
> I guess we should CC x86 maintainers then!

Its also a know BIOS problem with Dell f.e. They often indicate more
potential cpus even if this particular hw configuration cannot do cpu
hotplug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
