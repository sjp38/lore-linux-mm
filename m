Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 34F0D6B0031
	for <linux-mm@kvack.org>; Thu, 19 Sep 2013 14:58:29 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id lf1so10059368pab.10
        for <linux-mm@kvack.org>; Thu, 19 Sep 2013 11:58:28 -0700 (PDT)
Date: Thu, 19 Sep 2013 18:58:25 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: RFC vmstat: On demand vmstat threads
In-Reply-To: <alpine.DEB.2.02.1309190033440.4089@ionos.tec.linutronix.de>
Message-ID: <000001413796641f-017482d3-1194-499b-8f2a-d7686c1ae61f-000000@email.amazonses.com>
References: <00000140e9dfd6bd-40db3d4f-c1be-434f-8132-7820f81bb586-000000@email.amazonses.com> <CAOtvUMdfqyg80_9J8AnOaAdahuRYGC-bpemdo_oucDBPguXbVA@mail.gmail.com> <0000014109b8e5db-4b0f577e-c3b4-47fe-b7f2-0e5febbcc948-000000@email.amazonses.com>
 <20130918150659.5091a2c3ca94b99304427ec5@linux-foundation.org> <alpine.DEB.2.02.1309190033440.4089@ionos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>

On Thu, 19 Sep 2013, Thomas Gleixner wrote:

> The vmstat accounting is not the only thing which we want to delegate
> to dedicated core(s) for the full NOHZ mode.
>
> So instead of playing broken games with explicitly not exposed core
> code variables, we should implement a core code facility which is
> aware of the NOHZ details and provides a sane way to delegate stuff to
> a certain subset of CPUs.

I would be happy to use such a facility. Otherwise I would just be adding
yet another kernel option or boot parameter I guess.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
