Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id DAEE26B0035
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 09:56:10 -0400 (EDT)
Received: by mail-qc0-f182.google.com with SMTP id r5so176238qcx.13
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 06:56:10 -0700 (PDT)
Received: from qmta04.emeryville.ca.mail.comcast.net (qmta04.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:40])
        by mx.google.com with ESMTP id l81si3616710qga.1.2014.07.11.06.56.08
        for <linux-mm@kvack.org>;
        Fri, 11 Jul 2014 06:56:09 -0700 (PDT)
Date: Fri, 11 Jul 2014 08:56:04 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: vmstat: On demand vmstat workers V8
In-Reply-To: <20140711132032.GB26045@localhost.localdomain>
Message-ID: <alpine.DEB.2.11.1407110855030.25432@gentwo.org>
References: <alpine.DEB.2.11.1407100903130.12483@gentwo.org> <20140711132032.GB26045@localhost.localdomain>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: akpm@linux-foundation.org, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org

On Fri, 11 Jul 2014, Frederic Weisbecker wrote:

> > @@ -1228,20 +1244,105 @@ static const struct file_operations proc
> >  #ifdef CONFIG_SMP
> >  static DEFINE_PER_CPU(struct delayed_work, vmstat_work);
> >  int sysctl_stat_interval __read_mostly = HZ;
> > +struct cpumask *cpu_stat_off;
>
> I thought you converted it?

Converted what? We still need to keep a cpumask around that tells us which
processor have vmstat running and which do not.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
