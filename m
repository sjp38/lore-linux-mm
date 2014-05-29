Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f170.google.com (mail-vc0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id C9E5A6B0039
	for <linux-mm@kvack.org>; Thu, 29 May 2014 12:24:20 -0400 (EDT)
Received: by mail-vc0-f170.google.com with SMTP id la4so662308vcb.1
        for <linux-mm@kvack.org>; Thu, 29 May 2014 09:24:20 -0700 (PDT)
Received: from qmta04.emeryville.ca.mail.comcast.net (qmta04.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:40])
        by mx.google.com with ESMTP id s14si861368vem.73.2014.05.29.09.24.19
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 09:24:20 -0700 (PDT)
Date: Thu, 29 May 2014 11:24:15 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: vmstat: On demand vmstat workers V5
In-Reply-To: <20140529142602.GA20258@localhost.localdomain>
Message-ID: <alpine.DEB.2.10.1405291121400.12545@gentwo.org>
References: <alpine.DEB.2.10.1405121317270.29911@gentwo.org> <20140528152107.GB6507@localhost.localdomain> <alpine.DEB.2.10.1405281110210.22514@gentwo.org> <20140529003609.GG6507@localhost.localdomain> <alpine.DEB.2.10.1405290902180.11514@gentwo.org>
 <20140529142602.GA20258@localhost.localdomain>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org

On Thu, 29 May 2014, Frederic Weisbecker wrote:

> > Well yes and I am tying directly into that scheme there in cpu.c to
> > display the active vmstat threads in sysfs. so its the same.
>
> I don't think so. Or is there something in vmstat that cpumask_var_t
> definition depends upon?

This patch definitely ties the vmstat cpumask into the scheme in cpu.c

> > I would like to have some way to display the activities on cpus in /sysfs
> > like I have done here with the active vmstat workers.
> >
> > What I think we need is display cpumasks for
> >
> > 1. Cpus where the tick is currently off
> > 2. Cpus that have dynticks enabled.
> > 3. Cpus that are idle
>
> You should find all that in /proc/timer_list

True. I could actually drop the vmstat cpumask support.

> Now for CPUs that have full dynticks enabled, we probably need something
> in sysfs. We could dump the nohz cpumask somewhere. For now you can only grep
> the dmesg

There is a nohz mode in /proc/timer_list right?

> > 4. Cpus that are used for RCU.
>
> So, you mean those that aren't in extended grace period (between rcu_user_enter()/exit
> or rcu_idle_enter/exit)?

No I mean cpus that have their RCU processing directed to another
processor.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
