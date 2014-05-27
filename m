Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f182.google.com (mail-ve0-f182.google.com [209.85.128.182])
	by kanga.kvack.org (Postfix) with ESMTP id 864226B0036
	for <linux-mm@kvack.org>; Tue, 27 May 2014 16:07:50 -0400 (EDT)
Received: by mail-ve0-f182.google.com with SMTP id sa20so11558292veb.27
        for <linux-mm@kvack.org>; Tue, 27 May 2014 13:07:50 -0700 (PDT)
Received: from qmta10.emeryville.ca.mail.comcast.net (qmta10.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:17])
        by mx.google.com with ESMTP id cb8si8911413vcb.36.2014.05.27.13.07.49
        for <linux-mm@kvack.org>;
        Tue, 27 May 2014 13:07:49 -0700 (PDT)
Date: Tue, 27 May 2014 15:07:45 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: vmstat: On demand vmstat workers V5
In-Reply-To: <alpine.DEB.2.02.1405150111480.6261@ionos.tec.linutronix.de>
Message-ID: <alpine.DEB.2.10.1405271507090.15990@gentwo.org>
References: <alpine.DEB.2.10.1405121317270.29911@gentwo.org> <alpine.DEB.2.02.1405131651120.6261@ionos.tec.linutronix.de> <alpine.DEB.2.10.1405141105370.16512@gentwo.org> <alpine.DEB.2.02.1405150111480.6261@ionos.tec.linutronix.de>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org

On Thu, 15 May 2014, Thomas Gleixner wrote:

> Acked-by me for the general approach.
>
> I don't want to give any unqualified opinion on the mm/vmstat parts of
> this patch.

Thanks. Any other comments? Could we get this into -next?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
