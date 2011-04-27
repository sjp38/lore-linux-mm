Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 39E916B0012
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 19:54:27 -0400 (EDT)
Received: from mail-ew0-f41.google.com (mail-ew0-f41.google.com [209.85.215.41])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p3RNsNPd025954
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 16:54:25 -0700
Received: by ewy9 with SMTP id 9so963045ewy.14
        for <linux-mm@kvack.org>; Wed, 27 Apr 2011 16:54:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi=Ad2DUQ2Lr-Q5Y+eYxKMyz04fL2g@mail.gmail.com>
References: <20110425214933.GO2468@linux.vnet.ibm.com> <20110426081904.0d2b1494@pluto.restena.lu>
 <20110426112756.GF4308@linux.vnet.ibm.com> <20110426183859.6ff6279b@neptune.home>
 <20110426190918.01660ccf@neptune.home> <BANLkTikjuqWP+PAsObJH4EAOyzgr2RbYNA@mail.gmail.com>
 <alpine.LFD.2.02.1104262314110.3323@ionos> <20110427081501.5ba28155@pluto.restena.lu>
 <20110427204139.1b0ea23b@neptune.home> <alpine.LFD.2.02.1104272351290.3323@ionos>
 <20110427222727.GU2135@linux.vnet.ibm.com> <alpine.LFD.2.02.1104280028250.3323@ionos>
 <BANLkTi=Ad2DUQ2Lr-Q5Y+eYxKMyz04fL2g@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 27 Apr 2011 16:46:16 -0700
Message-ID: <BANLkTikknBQeSi0w7LeUTwSiMed-6LNKBw@mail.gmail.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning, regression?
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, =?ISO-8859-1?Q?Bruno_Pr=E9mont?= <bonbons@linux-vserver.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Wed, Apr 27, 2011 at 4:28 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> We _know_ it didn't run continuously for 950ms. That number is totally
> made up. There's not enough work for it to run that long, but more
> importantly, the thread has zero CPU time. There is _zero_ reason to
> believe that it runs for long periods.

Hmm. But it might certainly have run for a _total_ of 950ms. Since
that's just under a second, we wouldn't see it in the "ps" output.

Where is rt_time cleared? I see that subtract in
do_sched_rt_period_timer(), but judging by the caller that is only
called for some timer overrun case (I didn't look at what the
definition of such an overrun is, though). Shouldn't rt_time be
cleared when the task goes to sleep voluntarily?

What am I missing?

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
