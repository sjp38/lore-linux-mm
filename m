Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id D7D3C6B0083
	for <linux-mm@kvack.org>; Thu,  3 May 2012 03:24:47 -0400 (EDT)
Received: by lagz14 with SMTP id z14so1496035lag.14
        for <linux-mm@kvack.org>; Thu, 03 May 2012 00:24:45 -0700 (PDT)
Date: Thu, 3 May 2012 10:24:42 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: vmevent: question?
In-Reply-To: <4F9E4F0A.8030900@kernel.org>
Message-ID: <alpine.LFD.2.02.1205031019410.3686@tux.localdomain>
References: <4F9E39F1.5030600@kernel.org> <CAOJsxLE3A3b5HSrRm0NVCBmzv7AAs-RWEiZC1BL=se309+=WTA@mail.gmail.com> <4F9E44AD.8020701@kernel.org> <CAOJsxLGd_-ZSxpY2sL8XqyiYxpnmYDJJ+Hfx-zi1Ty=-1igcLA@mail.gmail.com> <4F9E4F0A.8030900@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <anton.vorontsov@linaro.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>

On Mon, 30 Apr 2012, Minchan Kim wrote:
> > What kind of consistency guarantees do you mean? The data sent to
> > userspace is always a snapshot of the state and therefore can be stale
> > by the time it reaches userspace.
> 
> Consistency between component of snapshot.
> let's assume following as
> 
> 1. User expect some events's value would be minus when event he expect happen.
>    A : -3, B : -4, C : -5, D : -6
> 2. Logically, it's not possible to mix plus and minus values for the events.
>    A : -3, B : -4, C : -5, D : -6 ( O )
>    A : -3, B : -4, C : 1, D : 2   ( X )
>    
> But in current implementation, some of those could be minus and some of those could be plus.
> Which event could user believe?
> At least, we need a _captured_ value when event triggered so that user can ignore other values.

Sorry, I still don't quite understand the problem.

The current implementation provides the same kind of snapshot consistency 
as reading from /proc/vmstat does (modulo the fact that we read them 
twice) for the values we support.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
