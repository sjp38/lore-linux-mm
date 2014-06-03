Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3BBB96B0031
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 12:55:33 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id x12so6978535wgg.33
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 09:55:32 -0700 (PDT)
Received: from mail-we0-x235.google.com (mail-we0-x235.google.com [2a00:1450:400c:c03::235])
        by mx.google.com with ESMTPS id cz7si33425407wjc.121.2014.06.03.09.55.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Jun 2014 09:55:31 -0700 (PDT)
Received: by mail-we0-f181.google.com with SMTP id w61so7076220wes.40
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 09:55:31 -0700 (PDT)
Date: Tue, 3 Jun 2014 18:55:28 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH] vmstat: on demand updates from differentials V7
Message-ID: <20140603165526.GG23860@localhost.localdomain>
References: <alpine.DEB.2.10.1405291453260.2899@gentwo.org>
 <20140603160953.GF23860@localhost.localdomain>
 <alpine.DEB.2.10.1406031136390.14380@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1406031136390.14380@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>

On Tue, Jun 03, 2014 at 11:38:02AM -0500, Christoph Lameter wrote:
> On Tue, 3 Jun 2014, Frederic Weisbecker wrote:
> 
> > So after the cpumask_var_t conversion I have no other concern except
> 
> Is there some way to observe which worker threads are queued on which
> processor? I see nothing in /sys/devices/virtual/workqueues (urg should be
> /sys/kernel/workqueues) that shows that?

Yeah you can see that with workqueue tracing events.

Check out /sys/kernel/debug/tracing/events/workqueue/ and more specifically
workqueue_execute_start/ and workqueue_queue_work/.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
