Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7B3EB6B0007
	for <linux-mm@kvack.org>; Mon, 14 May 2018 13:36:07 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f11-v6so11728631plj.23
        for <linux-mm@kvack.org>; Mon, 14 May 2018 10:36:07 -0700 (PDT)
Received: from esa2.hgst.iphmx.com (esa2.hgst.iphmx.com. [68.232.143.124])
        by mx.google.com with ESMTPS id x12-v6si7790040pgv.389.2018.05.14.10.36.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 May 2018 10:36:06 -0700 (PDT)
Subject: Re: [PATCH 0/7] psi: pressure stall information for CPU, memory, and
 IO
References: <20180507210135.1823-1-hannes@cmpxchg.org>
 <010001635f4e8be9-94e7be7a-e75c-438c-bffb-5b56301c4c55-000000@email.amazonses.com>
From: Bart Van Assche <bart.vanassche@wdc.com>
Message-ID: <cb81b9f2-a280-d8a9-c720-247fb9f5fa90@wdc.com>
Date: Mon, 14 May 2018 10:35:37 -0700
MIME-Version: 1.0
In-Reply-To: <010001635f4e8be9-94e7be7a-e75c-438c-bffb-5b56301c4c55-000000@email.amazonses.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, cgroups@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

On 05/14/18 08:39, Christopher Lameter wrote:
> On Mon, 7 May 2018, Johannes Weiner wrote:
>> What to make of this number? If CPU utilization is at 100% and CPU
>> pressure is 0, it means the system is perfectly utilized, with one
>> runnable thread per CPU and nobody waiting. At two or more runnable
>> tasks per CPU, the system is 100% overcommitted and the pressure
>> average will indicate as much. From a utilization perspective this is
>> a great state of course: no CPU cycles are being wasted, even when 50%
>> of the threads were to go idle (and most workloads do vary). From the
>> perspective of the individual job it's not great, however, and they
>> might do better with more resources. Depending on what your priority
>> is, an elevated "some" number may or may not require action.
> 
> This looks awfully similar to loadavg. Problem is that loadavg gets
> screwed up by tasks blocked waiting for I/O. Isnt there some way to fix
> loadavg instead?

The following article explains why it probably made sense in 1993 to 
include TASK_UNINTERRUPTIBLE in loadavg and also why this no longer 
makes sense today:

http://www.brendangregg.com/blog/2017-08-08/linux-load-averages.html

Bart.
