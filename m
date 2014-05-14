Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id D65096B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 19:15:15 -0400 (EDT)
Received: by mail-ee0-f54.google.com with SMTP id b57so135410eek.27
        for <linux-mm@kvack.org>; Wed, 14 May 2014 16:15:15 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id i49si2708279eem.132.2014.05.14.16.15.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 14 May 2014 16:15:14 -0700 (PDT)
Date: Thu, 15 May 2014 01:15:17 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: vmstat: On demand vmstat workers V5
In-Reply-To: <alpine.DEB.2.10.1405141105370.16512@gentwo.org>
Message-ID: <alpine.DEB.2.02.1405150111480.6261@ionos.tec.linutronix.de>
References: <alpine.DEB.2.10.1405121317270.29911@gentwo.org> <alpine.DEB.2.02.1405131651120.6261@ionos.tec.linutronix.de> <alpine.DEB.2.10.1405141105370.16512@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org

On Wed, 14 May 2014, Christoph Lameter wrote:
> - Shepherd thread as a general worker thread. This means
>   that the general mechanism to control worker thread
>   cpu proposed by Frederic Weisbecker is necessary to
>   restrict the shepherd thread to the cpus not used
>   for low latency tasks. Hopefully that is ready to be
>   merged soon. No need anymore to have a specific
>   cpu be the housekeeper cpu.

Amen to that.

Acked-by me for the general approach.

I don't want to give any unqualified opinion on the mm/vmstat parts of
this patch.

Thanks,

	tglx


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
