Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 40E4B6B0035
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 09:38:43 -0400 (EDT)
Received: by mail-qc0-f172.google.com with SMTP id i8so5420834qcq.3
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 06:38:43 -0700 (PDT)
Received: from qmta04.emeryville.ca.mail.comcast.net (qmta04.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:40])
        by mx.google.com with ESMTP id i1si16831301qab.274.2014.04.22.06.38.42
        for <linux-mm@kvack.org>;
        Tue, 22 Apr 2014 06:38:42 -0700 (PDT)
Date: Tue, 22 Apr 2014 08:38:38 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: vmstat: On demand vmstat workers V3
In-Reply-To: <CAOh2x==yrBdFDcObdz+La0y=jDERj=sxOBMvU-Kk6eGEvvwZQw@mail.gmail.com>
Message-ID: <alpine.DEB.2.10.1404220838090.4299@gentwo.org>
References: <000001417f6834f1-32b83f22-8bde-4b9e-b591-bc31329660e4-000000@email.amazonses.com> <CAOh2x==yrBdFDcObdz+La0y=jDERj=sxOBMvU-Kk6eGEvvwZQw@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viresh Kumar <viresh.kumar@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, 22 Apr 2014, Viresh Kumar wrote:

> On Thu, Oct 3, 2013 at 11:10 PM, Christoph Lameter <cl@linux.com> wrote:
> > V2->V3:
> > - Introduce a new tick_get_housekeeping_cpu() function. Not sure
> >   if that is exactly what we want but it is a start. Thomas?
> > - Migrate the shepherd task if the output of
> >   tick_get_housekeeping_cpu() changes.
> > - Fixes recommended by Andrew.
>
> This vmstat interrupt is disturbing my core isolation :), have you got
> any far with this patchset?

Sorry no too much other stuff. Would be glad if you could improve on it.
Should have some time on Friday to look at it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
