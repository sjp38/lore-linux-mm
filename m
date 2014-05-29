Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f179.google.com (mail-ve0-f179.google.com [209.85.128.179])
	by kanga.kvack.org (Postfix) with ESMTP id 491AB6B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 10:07:51 -0400 (EDT)
Received: by mail-ve0-f179.google.com with SMTP id oy12so431113veb.10
        for <linux-mm@kvack.org>; Thu, 29 May 2014 07:07:51 -0700 (PDT)
Received: from qmta12.emeryville.ca.mail.comcast.net (qmta12.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:227])
        by mx.google.com with ESMTP id k4si495248vch.63.2014.05.29.07.07.50
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 07:07:50 -0700 (PDT)
Date: Thu, 29 May 2014 09:07:44 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: vmstat: On demand vmstat workers V5
In-Reply-To: <20140529003609.GG6507@localhost.localdomain>
Message-ID: <alpine.DEB.2.10.1405290902180.11514@gentwo.org>
References: <alpine.DEB.2.10.1405121317270.29911@gentwo.org> <20140528152107.GB6507@localhost.localdomain> <alpine.DEB.2.10.1405281110210.22514@gentwo.org> <20140529003609.GG6507@localhost.localdomain>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org

On Thu, 29 May 2014, Frederic Weisbecker wrote:

> The cpumasks in cpu.c are special as they are the base of the cpumask_var_t
> definition. They are necessary to define nr_cpu_bits which is the base of
> cpumask_var_t allocations. As such they must stay lower level and defined
> on top of NR_CPUS.
>
> But most other cases don't need that huge static bitmap. I actually haven't
> seen any other struct cpumask than isn't based on cpumask_var_t.

Well yes and I am tying directly into that scheme there in cpu.c to
display the active vmstat threads in sysfs. so its the same.

> Please post it on a new thread so it gets noticed by others.

Ok. Will do when we got agreement on the cpumask issue.

I would like to have some way to display the activities on cpus in /sysfs
like I have done here with the active vmstat workers.

What I think we need is display cpumasks for

1. Cpus where the tick is currently off
2. Cpus that have dynticks enabled.
3. Cpus that are idle
4. Cpus that are used for RCU.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
