Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f182.google.com (mail-vc0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3249F6B0035
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 11:26:26 -0400 (EDT)
Received: by mail-vc0-f182.google.com with SMTP id hy4so13633568vcb.41
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 08:26:25 -0700 (PDT)
Received: from qmta04.emeryville.ca.mail.comcast.net (qmta04.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:40])
        by mx.google.com with ESMTP id cj3si3700150qcb.26.2014.07.29.08.26.25
        for <linux-mm@kvack.org>;
        Tue, 29 Jul 2014 08:26:25 -0700 (PDT)
Date: Tue, 29 Jul 2014 10:26:08 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: vmstat: On demand vmstat workers V8
In-Reply-To: <20140729151415.GF4791@htj.dyndns.org>
Message-ID: <alpine.DEB.2.11.1407291024300.21390@gentwo.org>
References: <alpine.DEB.2.11.1407100903130.12483@gentwo.org> <53D31101.8000107@oracle.com> <alpine.DEB.2.11.1407281353450.15405@gentwo.org> <20140729075637.GA19379@twins.programming.kicks-ass.net> <20140729120525.GA28366@mtj.dyndns.org> <20140729122303.GA3935@laptop>
 <20140729131226.GS7462@htj.dyndns.org> <alpine.DEB.2.11.1407291009320.21102@gentwo.org> <20140729151415.GF4791@htj.dyndns.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Sasha Levin <sasha.levin@oracle.com>, akpm@linux-foundation.org, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, Lai Jiangshan <laijs@cn.fujitsu.com>

On Tue, 29 Jul 2014, Tejun Heo wrote:

> > mm/vmstat.c already has cpu down hooks. See vmstat_cpuup_callback().
>
> Hmmm, well, then it's something else.  Either a bug in workqueue or in
> the caller.  Given the track record, the latter is more likely.
> e.g. it looks kinda suspicious that the work func is cleared after
> cancel_delayed_work_sync() is called.  What happens if somebody tries

Ok we can clear it before then.

Just looked at the current upstream code. It also does a __this_cpu_read()
in refresh_cpu_stats() without triggering the preemption check. What
changed in -next that made the test trigger now?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
