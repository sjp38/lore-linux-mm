Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0426C6B0036
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 14:55:21 -0400 (EDT)
Received: by mail-qg0-f45.google.com with SMTP id f51so9007038qge.32
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 11:55:21 -0700 (PDT)
Received: from qmta12.emeryville.ca.mail.comcast.net (qmta12.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:227])
        by mx.google.com with ESMTPS id 34si33562832qgq.78.2014.07.28.11.55.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 28 Jul 2014 11:55:21 -0700 (PDT)
Date: Mon, 28 Jul 2014 13:55:17 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: vmstat: On demand vmstat workers V8
In-Reply-To: <53D31101.8000107@oracle.com>
Message-ID: <alpine.DEB.2.11.1407281353450.15405@gentwo.org>
References: <alpine.DEB.2.11.1407100903130.12483@gentwo.org> <53D31101.8000107@oracle.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: akpm@linux-foundation.org, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org

On Fri, 25 Jul 2014, Sasha Levin wrote:

> This patch doesn't interact well with my fuzzing setup. I'm seeing
> the following:
>
> [  490.446927] BUG: using __this_cpu_read() in preemptible [00000000] code: kworker/16:1/7368
> [  490.447909] caller is __this_cpu_preempt_check+0x13/0x20

__this_cpu_read() from vmstat_update is only called from a kworker that
is bound to a single cpu. A false positive?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
