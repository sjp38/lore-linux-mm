Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 190606B0031
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 11:43:49 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id r20so6715376wiv.15
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 08:43:46 -0700 (PDT)
Received: from mail-we0-x231.google.com (mail-we0-x231.google.com [2a00:1450:400c:c03::231])
        by mx.google.com with ESMTPS id vr10si33149410wjc.65.2014.06.03.08.43.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Jun 2014 08:43:46 -0700 (PDT)
Received: by mail-we0-f177.google.com with SMTP id x48so6898466wes.22
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 08:43:45 -0700 (PDT)
Date: Tue, 3 Jun 2014 17:43:42 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH] vmstat: on demand updates from differentials V7
Message-ID: <20140603154339.GE23860@localhost.localdomain>
References: <alpine.DEB.2.10.1405291453260.2899@gentwo.org>
 <20140530000610.GB25555@localhost.localdomain>
 <alpine.DEB.2.10.1405300851490.8240@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1405300851490.8240@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>

On Fri, May 30, 2014 at 08:52:42AM -0500, Christoph Lameter wrote:
> On Fri, 30 May 2014, Frederic Weisbecker wrote:
> 
> > > +	cpu_stat_off = kmalloc(cpumask_size(), GFP_KERNEL);
> > > +	cpumask_copy(cpu_stat_off, cpu_online_mask);
> >
> > Actually looks like you can as well remove that cpumask and use
> > cpu_online_mask directly.
> 
> That would mean I would offline cpus that do not need the
> vmstat worker?

I missed that works adaptively set or clear cpus from the mask. Nevermind,
just ignore what I said.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
