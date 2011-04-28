Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4B11F6B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 02:22:34 -0400 (EDT)
Date: Thu, 28 Apr 2011 08:22:29 +0200
From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
Message-ID: <20110428082229.187c38c6@pluto.restena.lu>
In-Reply-To: <20110427215549.GN2135@linux.vnet.ibm.com>
References: <20110425191607.GL2468@linux.vnet.ibm.com>
	<20110425231016.34b4293e@neptune.home>
	<BANLkTin7wSGi1=E2c2u6Jb5TG_KUpYh=Dw@mail.gmail.com>
	<20110425214933.GO2468@linux.vnet.ibm.com>
	<20110426081904.0d2b1494@pluto.restena.lu>
	<20110426112756.GF4308@linux.vnet.ibm.com>
	<20110426183859.6ff6279b@neptune.home>
	<20110426190918.01660ccf@neptune.home>
	<BANLkTikjuqWP+PAsObJH4EAOyzgr2RbYNA@mail.gmail.com>
	<alpine.LFD.2.02.1104262314110.3323@ionos>
	<20110427215549.GN2135@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com
Cc: Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Wed, 27 Apr 2011 14:55:49 "Paul E. McKenney" wrote:
> On Wed, Apr 27, 2011 at 12:28:37AM +0200, Thomas Gleixner wrote:
> > On Tue, 26 Apr 2011, Linus Torvalds wrote:
> > > Normally SCHED_FIFO runs until it voluntarily gives up the CPU. That's
> > > kind of the point of SCHED_FIFO. Involuntary context switches happen
> > > when some higher-priority SCHED_FIFO process becomes runnable (irq
> > > handlers? You _do_ have CONFIG_IRQ_FORCED_THREADING=y in your config
> > > too), and maybe there is a bug in the runqueue handling for that case.
> > 
> > The forced irq threading is only effective when you add the command
> > line parameter "threadirqs". I don't see any irq threads in the ps
> > outputs, so that's not the problem.
> > 
> > Though the whole ps output is weird. There is only one thread/process
> > which accumulated CPU time
> > 
> > collectd  1605  0.6  0.7  49924  3748 ?        SNLsl 22:14   0:14
> 
> I believe that the above is the script that prints out the RCU debugfs
> information periodically.  Unless there is something else that begins
> with "collectd" instead of just collectdebugfs.sh.

No, collectd is a multi-threaded daemon that collects statistics of all
kinds, see  http://www.collectd.org/  for details (on my machine it
collects CPU usage, memory usage [just the basics], disk statistics,
network statistics load and a few more)

Bruno

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
