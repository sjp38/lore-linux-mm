Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id D83476B0037
	for <linux-mm@kvack.org>; Sat, 10 May 2014 08:22:47 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id e49so3320489eek.35
        for <linux-mm@kvack.org>; Sat, 10 May 2014 05:22:47 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id c6si6221916eem.0.2014.05.10.05.22.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Sat, 10 May 2014 05:22:46 -0700 (PDT)
Date: Sat, 10 May 2014 14:22:53 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: vmstat: On demand vmstat workers V4
In-Reply-To: <20140510003446.GA32393@localhost.localdomain>
Message-ID: <alpine.DEB.2.02.1405101421120.6261@ionos.tec.linutronix.de>
References: <alpine.DEB.2.10.1405081033090.23786@gentwo.org> <20140508142903.c2ef166c95d2b8acd0d7ea7d@linux-foundation.org> <alpine.DEB.2.02.1405090003120.6261@ionos.tec.linutronix.de> <alpine.DEB.2.10.1405090949170.11318@gentwo.org>
 <alpine.DEB.2.02.1405091659350.6261@ionos.tec.linutronix.de> <alpine.DEB.2.10.1405091027040.11318@gentwo.org> <alpine.DEB.2.02.1405092358390.6261@ionos.tec.linutronix.de> <20140510003446.GA32393@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Tejun Heo <tj@kernel.org>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, John Stultz <john.stultz@linaro.org>

On Sat, 10 May 2014, Frederic Weisbecker wrote:
> Anyway I agree that was overengineering at this stage.
> 
> Fortunately nothing has been applied. I was too busy with cleanups and workqueues
> affinity.

Good.
 
> So the "only" damage is on bad directions given to Christoph. But you know
> how I use GPS...

Yeah, especially when it's switched to 'Frederic universe' mode :)

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
