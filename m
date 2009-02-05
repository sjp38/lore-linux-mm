Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D54D46B004F
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 14:41:37 -0500 (EST)
Date: Thu, 5 Feb 2009 20:41:25 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 2.6.28 1/2] memory: improve find_vma
Message-ID: <20090205194125.GA3129@elte.hu>
References: <8c5a844a0901220851g1c21169al4452825564487b9a@mail.gmail.com> <Pine.LNX.4.64.0901221658550.14302@blonde.anvils> <8c5a844a0901221500m7af8ff45v169b6523ad9d7ad3@mail.gmail.com> <20090122231358.GA27033@elte.hu> <8c5a844a0901230310h7aa1ec83h60817de2b36212d8@mail.gmail.com> <8c5a844a0901281331w4cea7ab2y305d5a1af96e313e@mail.gmail.com> <20090129141929.GP24391@elte.hu> <8c5a844a0902010319t20b853d0t6c156ecc84543f30@mail.gmail.com> <20090201130058.GA486@elte.hu> <8c5a844a0902050326v2155dbeaq5449f1e373f4245d@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8c5a844a0902050326v2155dbeaq5449f1e373f4245d@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Daniel Lowengrub <lowdanie@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


* Daniel Lowengrub <lowdanie@gmail.com> wrote:

> On Sun, Feb 1, 2009 at 3:00 PM, Ingo Molnar <mingo@elte.hu> wrote:
> >
> >  you should time it:
> >
> >  time ./mmap-perf
> >
> > and compare the before/after results.
> >
> >        Ingo
> >
> 
> I made a script that runs 'time ./mmap-perf' 100 times and outputs the
> average.  The output on the standard kernel was:
>
>  real: 1.022600
>  user: 0.135900
>  system: 0.852600
>
> The output after the patch was:
>
>  real: 0.815400
>  user: 0.113200
>  system: 0.622200
>
> These results were consistent which isn't surprising considering the
> fact that they themselves are averages.
> What do you think?

Those nymbers look very convincing to me, a cool 25.4% speedup!
mmap-perf is very MM intense - including vma lookup.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
