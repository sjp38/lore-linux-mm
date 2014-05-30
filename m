Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f176.google.com (mail-vc0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id B2D656B0039
	for <linux-mm@kvack.org>; Fri, 30 May 2014 09:52:46 -0400 (EDT)
Received: by mail-vc0-f176.google.com with SMTP id la4so2076003vcb.7
        for <linux-mm@kvack.org>; Fri, 30 May 2014 06:52:46 -0700 (PDT)
Received: from qmta11.emeryville.ca.mail.comcast.net (qmta11.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:211])
        by mx.google.com with ESMTP id z1si3018831vet.30.2014.05.30.06.52.45
        for <linux-mm@kvack.org>;
        Fri, 30 May 2014 06:52:46 -0700 (PDT)
Date: Fri, 30 May 2014 08:52:42 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] vmstat: on demand updates from differentials V7
In-Reply-To: <20140530000610.GB25555@localhost.localdomain>
Message-ID: <alpine.DEB.2.10.1405300851490.8240@gentwo.org>
References: <alpine.DEB.2.10.1405291453260.2899@gentwo.org> <20140530000610.GB25555@localhost.localdomain>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>

On Fri, 30 May 2014, Frederic Weisbecker wrote:

> > +	cpu_stat_off = kmalloc(cpumask_size(), GFP_KERNEL);
> > +	cpumask_copy(cpu_stat_off, cpu_online_mask);
>
> Actually looks like you can as well remove that cpumask and use
> cpu_online_mask directly.

That would mean I would offline cpus that do not need the
vmstat worker?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
