Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 44A436B0035
	for <linux-mm@kvack.org>; Mon,  4 Aug 2014 17:38:45 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id rd3so53551pab.14
        for <linux-mm@kvack.org>; Mon, 04 Aug 2014 14:38:44 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id pb6si9434905pdb.212.2014.08.04.14.38.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 04 Aug 2014 14:38:44 -0700 (PDT)
Message-ID: <53DFFD28.2030502@oracle.com>
Date: Mon, 04 Aug 2014 17:37:44 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: vmstat: On demand vmstat workers V8
References: <alpine.DEB.2.11.1407100903130.12483@gentwo.org> <53D31101.8000107@oracle.com>
In-Reply-To: <53D31101.8000107@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>, akpm@linux-foundation.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org

On 07/25/2014 10:22 PM, Sasha Levin wrote:
> On 07/10/2014 10:04 AM, Christoph Lameter wrote:
>> > This patch creates a vmstat shepherd worker that monitors the
>> > per cpu differentials on all processors. If there are differentials
>> > on a processor then a vmstat worker local to the processors
>> > with the differentials is created. That worker will then start
>> > folding the diffs in regular intervals. Should the worker
>> > find that there is no work to be done then it will make the shepherd
>> > worker monitor the differentials again.
> Hi Christoph, all,
> 
> This patch doesn't interact well with my fuzzing setup. I'm seeing
> the following:

I think we got sidetracked here a bit, I've noticed that this issue
is still happening in -next and discussions here died out.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
