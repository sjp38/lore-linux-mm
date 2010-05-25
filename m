Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D1FBC6008F9
	for <linux-mm@kvack.org>; Tue, 25 May 2010 06:47:32 -0400 (EDT)
Received: by fxm11 with SMTP id 11so2648966fxm.14
        for <linux-mm@kvack.org>; Tue, 25 May 2010 03:47:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1005250257100.8045@chino.kir.corp.google.com>
References: <20100521211452.659982351@quilx.com>
	<20100524070309.GU2516@laptop>
	<alpine.DEB.2.00.1005240852580.5045@router.home>
	<20100525020629.GA5087@laptop>
	<AANLkTik2O-_Fbh-dq0sSLFJyLU7PZi4DHm85lCo4sugS@mail.gmail.com>
	<20100525070734.GC5087@laptop>
	<AANLkTimhTfz_mMWNh_r18yapNxSDjA7wRDnFM6L5aIdE@mail.gmail.com>
	<alpine.DEB.2.00.1005250257100.8045@chino.kir.corp.google.com>
Date: Tue, 25 May 2010 13:47:30 +0300
Message-ID: <AANLkTin5PNELUXc6oCHadVyX-YcAEalRSppjz4GMyIBh@mail.gmail.com>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

Hi David,

On Tue, May 25, 2010 at 1:02 PM, David Rientjes <rientjes@google.com> wrote=
:
>> I wouldn't say it's a nightmare, but yes, it could be better. From my
>> point of view SLUB is the base of whatever the future will be because
>> the code is much cleaner and simpler than SLAB.
>
> The code may be much cleaner and simpler than slab, but nobody (to date)
> has addressed the significant netperf TCP_RR regression that slub has, fo=
r
> example. =A0I worked on a patchset to do that for a while but it wasn't
> popular because it added some increments to the fastpath for tracking
> data.

Yes and IIRC I asked you to resend the series because while I care a
lot about performance regressions, I simply don't have the time or the
hardware to reproduce and fix the weird cases you're seeing.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
