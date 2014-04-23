Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id 296FD6B0035
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 15:54:26 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id i17so1496965qcy.14
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 12:54:25 -0700 (PDT)
Received: from qmta06.emeryville.ca.mail.comcast.net (qmta06.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:56])
        by mx.google.com with ESMTP id h76si1053375qge.17.2014.04.23.12.54.25
        for <linux-mm@kvack.org>;
        Wed, 23 Apr 2014 12:54:25 -0700 (PDT)
Date: Wed, 23 Apr 2014 14:54:21 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: vmstat: On demand vmstat workers V3
In-Reply-To: <5357EF4D.6080302@qti.qualcomm.com>
Message-ID: <alpine.DEB.2.10.1404231453410.16224@gentwo.org>
References: <000001417f6834f1-32b83f22-8bde-4b9e-b591-bc31329660e4-000000@email.amazonses.com> <CAOh2x==yrBdFDcObdz+La0y=jDERj=sxOBMvU-Kk6eGEvvwZQw@mail.gmail.com> <5357EF4D.6080302@qti.qualcomm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Max Krasnyansky <maxk@qti.qualcomm.com>
Cc: Viresh Kumar <viresh.kumar@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed, 23 Apr 2014, Max Krasnyansky wrote:

> The updates are done via the regular priority workqueue.

Yup so things could be fixed at that level with setting an additional
workqueue flag?

> I'm playing with isolation as well (has been more or less a background thing
> for the last 6+ years). Our threads that run on the isolated cores are SCHED_FIFO
> and therefor low prio workqueue stuff, like vmstat, doesn't get in the way.
> I do have a few patches for the workqueues to make things better for isolation.

Would you share those with us please?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
