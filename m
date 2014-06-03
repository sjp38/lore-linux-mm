Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0438C6B0031
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 12:28:23 -0400 (EDT)
Received: by mail-qg0-f45.google.com with SMTP id z60so13551169qgd.18
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 09:28:23 -0700 (PDT)
Received: from qmta03.emeryville.ca.mail.comcast.net (qmta03.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:32])
        by mx.google.com with ESMTP id e10si22712727qcd.14.2014.06.03.09.28.23
        for <linux-mm@kvack.org>;
        Tue, 03 Jun 2014 09:28:23 -0700 (PDT)
Date: Tue, 3 Jun 2014 11:28:18 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] vmstat: on demand updates from differentials V7
In-Reply-To: <20140603160953.GF23860@localhost.localdomain>
Message-ID: <alpine.DEB.2.10.1406031127080.14380@gentwo.org>
References: <alpine.DEB.2.10.1405291453260.2899@gentwo.org> <20140603160953.GF23860@localhost.localdomain>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>

On Tue, 3 Jun 2014, Frederic Weisbecker wrote:

> So after the cpumask_var_t conversion I have no other concern except
> perhaps that the scan may bring some overhead on workloads that don't
> care about isolation. You might want to make it optional. But I let you
> check that.

Testing so far indicates that typical loads have spurts of kernel usage
which need vmstat but otherwise there are large segments of processing
that do not need the vmstat worker. It seems that this change is generally
helpful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
