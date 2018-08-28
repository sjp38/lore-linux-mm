Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id E7F636B482B
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 17:30:32 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id 40-v6so2026759wrb.23
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 14:30:32 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id y83-v6si1936072wmc.53.2018.08.28.14.30.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 Aug 2018 14:30:31 -0700 (PDT)
Subject: Re: [PATCH 8/9] psi: pressure stall information for CPU, memory, and
 IO
References: <20180828172258.3185-1-hannes@cmpxchg.org>
 <20180828172258.3185-9-hannes@cmpxchg.org>
 <6ff71c29-3b6a-4849-6f2a-3d829bbd43e2@infradead.org>
 <20180828205625.GA14030@cmpxchg.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <b0880165-9bc1-5eb4-bf6b-8e853879d463@infradead.org>
Date: Tue, 28 Aug 2018 14:30:17 -0700
MIME-Version: 1.0
In-Reply-To: <20180828205625.GA14030@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Peter Enderborg <peter.enderborg@sony.com>, Shakeel Butt <shakeelb@google.com>, Mike Galbraith <efault@gmx.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On 08/28/2018 01:56 PM, Johannes Weiner wrote:
> On Tue, Aug 28, 2018 at 01:11:11PM -0700, Randy Dunlap wrote:
>> On 08/28/2018 10:22 AM, Johannes Weiner wrote:
>>> diff --git a/Documentation/accounting/psi.txt b/Documentation/accounting/psi.txt
>>> new file mode 100644
>>> index 000000000000..51e7ef14142e
>>> --- /dev/null
>>> +++ b/Documentation/accounting/psi.txt
>>> @@ -0,0 +1,64 @@
>>> +================================
>>> +PSI - Pressure Stall Information
>>> +================================
>>> +
>>> +:Date: April, 2018
>>> +:Author: Johannes Weiner <hannes@cmpxchg.org>
>>> +
>>> +When CPU, memory or IO devices are contended, workloads experience
>>> +latency spikes, throughput losses, and run the risk of OOM kills.
>>> +
>>> +Without an accurate measure of such contention, users are forced to
>>> +either play it safe and under-utilize their hardware resources, or
>>> +roll the dice and frequently suffer the disruptions resulting from
>>> +excessive overcommit.
>>> +
>>> +The psi feature identifies and quantifies the disruptions caused by
>>> +such resource crunches and the time impact it has on complex workloads
>>> +or even entire systems.
>>> +
>>> +Having an accurate measure of productivity losses caused by resource
>>> +scarcity aids users in sizing workloads to hardware--or provisioning
>>> +hardware according to workload demand.
>>> +
>>> +As psi aggregates this information in realtime, systems can be managed
>>> +dynamically using techniques such as load shedding, migrating jobs to
>>> +other systems or data centers, or strategically pausing or killing low
>>> +priority or restartable batch jobs.
>>> +
>>> +This allows maximizing hardware utilization without sacrificing
>>> +workload health or risking major disruptions such as OOM kills.
>>> +
>>> +Pressure interface
>>> +==================
>>> +
>>> +Pressure information for each resource is exported through the
>>> +respective file in /proc/pressure/ -- cpu, memory, and io.
>>> +
>>
>> Hi,
>>
>>> +In both cases, the format for CPU is as such:
>>
>> I don't see what "In both cases" refers to here.  It seems that you could
>> just remove it.
> 
> You're right, that must be a left-over from when I described CPU
> separately; "both cases" referred to memory and IO which have
> identical formats. It needs to be removed:
> 
> diff --git a/Documentation/accounting/psi.txt b/Documentation/accounting/psi.txt
> index e051810d5127..b8ca28b60215 100644
> --- a/Documentation/accounting/psi.txt
> +++ b/Documentation/accounting/psi.txt
> @@ -35,7 +35,7 @@ Pressure interface
>  Pressure information for each resource is exported through the
>  respective file in /proc/pressure/ -- cpu, memory, and io.
>  
> -In both cases, the format for CPU is as such:
> +The format for CPU is as such:
>  
>  some avg10=0.00 avg60=0.00 avg300=0.00 total=0


OK.  However, after reading patch 9/9, I thought that the "both cases"
could possibly mean the files in /proc/pressure/ and the files in
cgroup ({cpu,io,memory}.pressure).

-- 
~Randy
