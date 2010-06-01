Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7CE9E6B01D6
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 15:52:21 -0400 (EDT)
Date: Tue, 1 Jun 2010 14:48:58 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Possible bug in 2.6.34 slub
In-Reply-To: <20100601123959.747228c6.rdunlap@xenotime.net>
Message-ID: <alpine.DEB.2.00.1006011445100.9438@router.home>
References: <AANLkTimEFy6VM3InWlqhVooQjKGSD3yBxlgeRbQC2r1L@mail.gmail.com> <20100531165528.35a323fb.rdunlap@xenotime.net> <4C047CF9.9000804@tmr.com> <AANLkTilLq-hn59CBcLnOsnT37ZizQR6MrZX6btKPhfpb@mail.gmail.com>
 <20100601123959.747228c6.rdunlap@xenotime.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: Giangiacomo Mariotti <gg.mariotti@gmail.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bill Davidsen <davidsen@tmr.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 1 Jun 2010, Randy Dunlap wrote:

> > >>> My cpu is an I7 920, so it has 4 cores and there's hyperthreading
> > >>> enabled, so there are 8 logical cpus. Is this a bug?

Yes its a bug in the arch code or BIOS. The system configuration tells us
that there are more possible cpus and therefore the system prepares for
the additional cpus to be activated at some later time.

> Sorry, I think that I misread your report.
> It does look like misinformation.
> Let's cc Christoph Lameter & Pekka.
>
>
> > The point is, I guess(didn't actually look at the code), if that's
> > just the count of MAX number of cpus supported, which is a config time
> >  define and then the actual count gets refined afterwards by slub
> > too(because I know that the rest of the kernel knows I've got 4
> > cores/8 logical cpus) or not. Is that it? If this is not the case(that
> > is, it's not a static define used as a MAX value), then I can't see
> > what kind of boot/init time info it is. If it's a boot-time info, it
> > just means it's a _wrong_ boot-time info.

No that is the max nr of cpus possible on this machine. The count is
determined by hardware capabilities on bootup. If they are not detected
in the right way then you have the erroneous display (and the system
configures useless per cpu structures to support nonexistent cpus).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
