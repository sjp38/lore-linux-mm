Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9DCA46B0035
	for <linux-mm@kvack.org>; Tue,  5 Aug 2014 18:26:45 -0400 (EDT)
Received: by mail-oi0-f43.google.com with SMTP id u20so1095950oif.30
        for <linux-mm@kvack.org>; Tue, 05 Aug 2014 15:26:45 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id ei10si7270703oeb.91.2014.08.05.15.26.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 05 Aug 2014 15:26:44 -0700 (PDT)
Message-ID: <53E159F6.7080603@oracle.com>
Date: Tue, 05 Aug 2014 18:25:58 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: vmstat: On demand vmstat workers V8
References: <alpine.DEB.2.11.1407100903130.12483@gentwo.org> <53D31101.8000107@oracle.com> <53DFFD28.2030502@oracle.com> <alpine.DEB.2.11.1408050950390.16902@gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1408050950390.16902@gentwo.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: akpm@linux-foundation.org, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org

On 08/05/2014 10:51 AM, Christoph Lameter wrote:
> On Mon, 4 Aug 2014, Sasha Levin wrote:
> 
>> On 07/25/2014 10:22 PM, Sasha Levin wrote:
>>> On 07/10/2014 10:04 AM, Christoph Lameter wrote:
>>>>> This patch creates a vmstat shepherd worker that monitors the
>>>>> per cpu differentials on all processors. If there are differentials
>>>>> on a processor then a vmstat worker local to the processors
>>>>> with the differentials is created. That worker will then start
>>>>> folding the diffs in regular intervals. Should the worker
>>>>> find that there is no work to be done then it will make the shepherd
>>>>> worker monitor the differentials again.
>>> Hi Christoph, all,
>>>
>>> This patch doesn't interact well with my fuzzing setup. I'm seeing
>>> the following:
>>
>> I think we got sidetracked here a bit, I've noticed that this issue
>> is still happening in -next and discussions here died out.
> 
> Ok I saw in another thread that this issue has gone away. Is there an
> easy way to reproduce this on my system?
> 

I don't see the VM_BUG_ON anymore, but the cpu warnings are still there.

I can easily trigger it by cranking up the cpu hotplug code. Just try to
frequently offline and online cpus, it should reproduce quickly.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
