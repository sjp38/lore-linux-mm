Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f171.google.com (mail-vc0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 98ECE6B0031
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 12:38:06 -0400 (EDT)
Received: by mail-vc0-f171.google.com with SMTP id ij19so2601007vcb.16
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 09:38:06 -0700 (PDT)
Received: from qmta11.emeryville.ca.mail.comcast.net (qmta11.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:211])
        by mx.google.com with ESMTP id za4si10238160vdb.43.2014.06.03.09.38.05
        for <linux-mm@kvack.org>;
        Tue, 03 Jun 2014 09:38:05 -0700 (PDT)
Date: Tue, 3 Jun 2014 11:38:02 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] vmstat: on demand updates from differentials V7
In-Reply-To: <20140603160953.GF23860@localhost.localdomain>
Message-ID: <alpine.DEB.2.10.1406031136390.14380@gentwo.org>
References: <alpine.DEB.2.10.1405291453260.2899@gentwo.org> <20140603160953.GF23860@localhost.localdomain>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>

On Tue, 3 Jun 2014, Frederic Weisbecker wrote:

> So after the cpumask_var_t conversion I have no other concern except

Is there some way to observe which worker threads are queued on which
processor? I see nothing in /sys/devices/virtual/workqueues (urg should be
/sys/kernel/workqueues) that shows that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
