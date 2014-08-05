Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id D256E6B0037
	for <linux-mm@kvack.org>; Tue,  5 Aug 2014 10:51:50 -0400 (EDT)
Received: by mail-qa0-f42.google.com with SMTP id j15so1049221qaq.29
        for <linux-mm@kvack.org>; Tue, 05 Aug 2014 07:51:50 -0700 (PDT)
Received: from qmta05.emeryville.ca.mail.comcast.net (qmta05.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:48])
        by mx.google.com with ESMTP id h6si3221709qah.32.2014.08.05.07.51.49
        for <linux-mm@kvack.org>;
        Tue, 05 Aug 2014 07:51:49 -0700 (PDT)
Date: Tue, 5 Aug 2014 09:51:44 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: vmstat: On demand vmstat workers V8
In-Reply-To: <53DFFD28.2030502@oracle.com>
Message-ID: <alpine.DEB.2.11.1408050950390.16902@gentwo.org>
References: <alpine.DEB.2.11.1407100903130.12483@gentwo.org> <53D31101.8000107@oracle.com> <53DFFD28.2030502@oracle.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: akpm@linux-foundation.org, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org

On Mon, 4 Aug 2014, Sasha Levin wrote:

> On 07/25/2014 10:22 PM, Sasha Levin wrote:
> > On 07/10/2014 10:04 AM, Christoph Lameter wrote:
> >> > This patch creates a vmstat shepherd worker that monitors the
> >> > per cpu differentials on all processors. If there are differentials
> >> > on a processor then a vmstat worker local to the processors
> >> > with the differentials is created. That worker will then start
> >> > folding the diffs in regular intervals. Should the worker
> >> > find that there is no work to be done then it will make the shepherd
> >> > worker monitor the differentials again.
> > Hi Christoph, all,
> >
> > This patch doesn't interact well with my fuzzing setup. I'm seeing
> > the following:
>
> I think we got sidetracked here a bit, I've noticed that this issue
> is still happening in -next and discussions here died out.

Ok I saw in another thread that this issue has gone away. Is there an
easy way to reproduce this on my system?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
