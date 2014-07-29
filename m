Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7FF336B0035
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 11:17:25 -0400 (EDT)
Received: by mail-qg0-f52.google.com with SMTP id f51so10363343qge.39
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 08:17:25 -0700 (PDT)
Received: from qmta06.emeryville.ca.mail.comcast.net (qmta06.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:56])
        by mx.google.com with ESMTP id w7si3614553qch.18.2014.07.29.08.17.24
        for <linux-mm@kvack.org>;
        Tue, 29 Jul 2014 08:17:24 -0700 (PDT)
Date: Tue, 29 Jul 2014 10:17:13 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: vmstat: On demand vmstat workers V8
In-Reply-To: <20140728145443.dce6fe72aed1bbdcf95b21f6@linux-foundation.org>
Message-ID: <alpine.DEB.2.11.1407291011230.21102@gentwo.org>
References: <alpine.DEB.2.11.1407100903130.12483@gentwo.org> <53D31101.8000107@oracle.com> <alpine.DEB.2.11.1407281353450.15405@gentwo.org> <20140728145443.dce6fe72aed1bbdcf95b21f6@linux-foundation.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org

On Mon, 28 Jul 2014, Andrew Morton wrote:

> Also, Sasha's report showed this:
>
> [  490.464613] kernel BUG at mm/vmstat.c:1278!
>
> That's your VM_BUG_ON() in vmstat_update().  That ain't no false
> positive!

AFAICT this is because of the earlier BUG().


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
