Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 97ED56B0035
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 10:34:22 -0400 (EDT)
Received: by mail-qg0-f48.google.com with SMTP id i50so1528802qgf.35
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 07:34:22 -0700 (PDT)
Received: from qmta12.emeryville.ca.mail.comcast.net (qmta12.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:227])
        by mx.google.com with ESMTP id i64si4186661qge.60.2014.07.30.07.34.20
        for <linux-mm@kvack.org>;
        Wed, 30 Jul 2014 07:34:21 -0700 (PDT)
Date: Wed, 30 Jul 2014 09:34:16 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: vmstat: On demand vmstat workers V8
In-Reply-To: <53D8626E.5060900@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.11.1407300933370.4608@gentwo.org>
References: <alpine.DEB.2.11.1407100903130.12483@gentwo.org> <53D31101.8000107@oracle.com> <alpine.DEB.2.11.1407281353450.15405@gentwo.org> <20140729075637.GA19379@twins.programming.kicks-ass.net> <20140729120525.GA28366@mtj.dyndns.org> <20140729122303.GA3935@laptop>
 <20140729131226.GS7462@htj.dyndns.org> <alpine.DEB.2.11.1407291009320.21102@gentwo.org> <20140729151415.GF4791@htj.dyndns.org> <alpine.DEB.2.11.1407291038160.21390@gentwo.org> <53D8626E.5060900@cn.fujitsu.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: Tejun Heo <tj@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Sasha Levin <sasha.levin@oracle.com>, akpm@linux-foundation.org, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org

On Wed, 30 Jul 2014, Lai Jiangshan wrote:

> >
> >
> > Index: linux/mm/vmstat.c
> > ===================================================================
> > --- linux.orig/mm/vmstat.c	2014-07-29 10:22:45.073884943 -0500
> > +++ linux/mm/vmstat.c	2014-07-29 10:34:45.083369228 -0500
> > @@ -1277,8 +1277,8 @@ static int vmstat_cpuup_callback(struct
> >  		break;
> >  	case CPU_DOWN_PREPARE:
> >  	case CPU_DOWN_PREPARE_FROZEN:
> > -		cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
> >  		per_cpu(vmstat_work, cpu).work.func = NULL;
> > +		cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
>
> I think we should just remove "per_cpu(vmstat_work, cpu).work.func = NULL;"

It has been removed by the vmstat patch. The patch I posted is against
upstream not against -next.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
