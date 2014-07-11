Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id B972F6B0035
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 09:59:05 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id ho1so1420324wib.10
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 06:59:04 -0700 (PDT)
Received: from mail-wg0-x22a.google.com (mail-wg0-x22a.google.com [2a00:1450:400c:c00::22a])
        by mx.google.com with ESMTPS id cr6si4240295wjb.64.2014.07.11.06.59.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 11 Jul 2014 06:59:04 -0700 (PDT)
Received: by mail-wg0-f42.google.com with SMTP id l18so1101588wgh.25
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 06:59:02 -0700 (PDT)
Date: Fri, 11 Jul 2014 15:58:56 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: vmstat: On demand vmstat workers V8
Message-ID: <20140711135854.GD26045@localhost.localdomain>
References: <alpine.DEB.2.11.1407100903130.12483@gentwo.org>
 <20140711132032.GB26045@localhost.localdomain>
 <alpine.DEB.2.11.1407110855030.25432@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1407110855030.25432@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: akpm@linux-foundation.org, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org

On Fri, Jul 11, 2014 at 08:56:04AM -0500, Christoph Lameter wrote:
> On Fri, 11 Jul 2014, Frederic Weisbecker wrote:
> 
> > > @@ -1228,20 +1244,105 @@ static const struct file_operations proc
> > >  #ifdef CONFIG_SMP
> > >  static DEFINE_PER_CPU(struct delayed_work, vmstat_work);
> > >  int sysctl_stat_interval __read_mostly = HZ;
> > > +struct cpumask *cpu_stat_off;
> >
> > I thought you converted it?
> 
> Converted what? We still need to keep a cpumask around that tells us which
> processor have vmstat running and which do not.
> 

Converted to cpumask_var_t.

I mean we spent dozens emails on that...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
