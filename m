Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5F7626B01CD
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 15:40:16 -0400 (EDT)
Received: from chimera.site ([71.245.98.113]) by xenotime.net for <linux-mm@kvack.org>; Tue, 1 Jun 2010 12:40:00 -0700
Date: Tue, 1 Jun 2010 12:39:59 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: Possible bug in 2.6.34 slub
Message-Id: <20100601123959.747228c6.rdunlap@xenotime.net>
In-Reply-To: <AANLkTilLq-hn59CBcLnOsnT37ZizQR6MrZX6btKPhfpb@mail.gmail.com>
References: <AANLkTimEFy6VM3InWlqhVooQjKGSD3yBxlgeRbQC2r1L@mail.gmail.com>
	<20100531165528.35a323fb.rdunlap@xenotime.net>
	<4C047CF9.9000804@tmr.com>
	<AANLkTilLq-hn59CBcLnOsnT37ZizQR6MrZX6btKPhfpb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Giangiacomo Mariotti <gg.mariotti@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Bill Davidsen <davidsen@tmr.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 1 Jun 2010 21:17:40 +0200 Giangiacomo Mariotti wrote:

> On Tue, Jun 1, 2010 at 5:22 AM, Bill Davidsen <davidsen@tmr.com> wrote:
> > Randy Dunlap wrote:
> >>
> >> On Tue, 1 Jun 2010 01:39:43 +0200 Giangiacomo Mariotti wrote:
> >>
> >>> Hi, I've recently noticed this line on the dmesg output(kernel 2.6.34=
):
> >>> [ =A0 =A00.000000] SLUB: Genslabs=3D14, HWalign=3D64, Order=3D0-3, Mi=
nObjects=3D0,
> >>> CPUs=3D16, Nodes=3D1
> >>>
> >>> My cpu is an I7 920, so it has 4 cores and there's hyperthreading
> >>> enabled, so there are 8 logical cpus. Is this a bug?
> >>
> >>
> >> No, it's just some boot/init time information.
> >>
> > I would consider it a bug to claim CPUs=3Dxx when xx is something other=
 than
> > the number of cores or the number of SMT threads supported by the proce=
ssor.
> > Of course if /proc/cpuinfo shows four siblings per core or something
> > exciting, then it's right and you have a CPU you can sell to gizmodo and
> > tell them a drunk left on the bar.
> >
> So....is it a bug or not?

Sorry, I think that I misread your report.
It does look like misinformation.
Let's cc Christoph Lameter & Pekka.


> The point is, I guess(didn't actually look at the code), if that's
> just the count of MAX number of cpus supported, which is a config time
>  define and then the actual count gets refined afterwards by slub
> too(because I know that the rest of the kernel knows I've got 4
> cores/8 logical cpus) or not. Is that it? If this is not the case(that
> is, it's not a static define used as a MAX value), then I can't see
> what kind of boot/init time info it is. If it's a boot-time info, it
> just means it's a _wrong_ boot-time info.



---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
