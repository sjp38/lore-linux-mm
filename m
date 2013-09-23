Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 32B806B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 11:05:30 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so3333734pdj.31
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 08:05:29 -0700 (PDT)
Date: Mon, 23 Sep 2013 15:03:27 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: RFC vmstat: On demand vmstat threads
In-Reply-To: <alpine.DEB.2.02.1309201238560.4089@ionos.tec.linutronix.de>
Message-ID: <000001414b58b5dd-f3b4dc76-8ec0-4694-b1f0-34e138a712a7-000000@email.amazonses.com>
References: <00000140e9dfd6bd-40db3d4f-c1be-434f-8132-7820f81bb586-000000@email.amazonses.com> <CAOtvUMdfqyg80_9J8AnOaAdahuRYGC-bpemdo_oucDBPguXbVA@mail.gmail.com> <0000014109b8e5db-4b0f577e-c3b4-47fe-b7f2-0e5febbcc948-000000@email.amazonses.com>
 <20130918150659.5091a2c3ca94b99304427ec5@linux-foundation.org> <alpine.DEB.2.02.1309190033440.4089@ionos.tec.linutronix.de> <000001413796641f-017482d3-1194-499b-8f2a-d7686c1ae61f-000000@email.amazonses.com>
 <alpine.DEB.2.02.1309201238560.4089@ionos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>

On Fri, 20 Sep 2013, Thomas Gleixner wrote:

> The whole delegation stuff is necessary not just for vmstat. We have
> the same issue for scheduler stats and other parts of the kernel, so
> we are better off in having a core facility to schedule such functions
> in consistency with the current full NOHZ state.

Ok how do I make use of such a facility? What is the status of work on
such a thing?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
