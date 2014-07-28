Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id AA9F86B0036
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 18:01:29 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id rd3so187886pab.40
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 15:01:29 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id dq7si5633293pdb.225.2014.07.28.15.01.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 28 Jul 2014 15:01:28 -0700 (PDT)
Message-ID: <53D6C80F.8010307@oracle.com>
Date: Mon, 28 Jul 2014 18:00:47 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: vmstat: On demand vmstat workers V8
References: <alpine.DEB.2.11.1407100903130.12483@gentwo.org>	<53D31101.8000107@oracle.com>	<alpine.DEB.2.11.1407281353450.15405@gentwo.org> <20140728145443.dce6fe72aed1bbdcf95b21f6@linux-foundation.org>
In-Reply-To: <20140728145443.dce6fe72aed1bbdcf95b21f6@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@gentwo.org>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org

On 07/28/2014 05:54 PM, Andrew Morton wrote:
> Also, Sasha's report showed this:
> 
> [  490.464613] kernel BUG at mm/vmstat.c:1278!
> 
> That's your VM_BUG_ON() in vmstat_update().  That ain't no false
> positive!
> 
> 
> 
> Is this code expecting that schedule_delayed_work() will schedule the
> work on the current CPU?  I don't think it will do that.  Maybe you
> should be looking at schedule_delayed_work_on().

I suspected that the re-queue might be wrong (schedule_delayed_work vs
schedule_delayed_work_on) and tried fixing that, but that didn't solve
the issue.

I could give it another go unless someone sees the issue, I might have
messed something up.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
