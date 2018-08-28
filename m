Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6895C6B47DA
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 16:11:29 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id y18-v6so1743771wma.9
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 13:11:29 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id m4-v6si1488750wrv.374.2018.08.28.13.11.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 Aug 2018 13:11:27 -0700 (PDT)
Subject: Re: [PATCH 8/9] psi: pressure stall information for CPU, memory, and
 IO
References: <20180828172258.3185-1-hannes@cmpxchg.org>
 <20180828172258.3185-9-hannes@cmpxchg.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <6ff71c29-3b6a-4849-6f2a-3d829bbd43e2@infradead.org>
Date: Tue, 28 Aug 2018 13:11:11 -0700
MIME-Version: 1.0
In-Reply-To: <20180828172258.3185-9-hannes@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Peter Enderborg <peter.enderborg@sony.com>, Shakeel Butt <shakeelb@google.com>, Mike Galbraith <efault@gmx.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On 08/28/2018 10:22 AM, Johannes Weiner wrote:
> diff --git a/Documentation/accounting/psi.txt b/Documentation/accounting/psi.txt
> new file mode 100644
> index 000000000000..51e7ef14142e
> --- /dev/null
> +++ b/Documentation/accounting/psi.txt
> @@ -0,0 +1,64 @@
> +================================
> +PSI - Pressure Stall Information
> +================================
> +
> +:Date: April, 2018
> +:Author: Johannes Weiner <hannes@cmpxchg.org>
> +
> +When CPU, memory or IO devices are contended, workloads experience
> +latency spikes, throughput losses, and run the risk of OOM kills.
> +
> +Without an accurate measure of such contention, users are forced to
> +either play it safe and under-utilize their hardware resources, or
> +roll the dice and frequently suffer the disruptions resulting from
> +excessive overcommit.
> +
> +The psi feature identifies and quantifies the disruptions caused by
> +such resource crunches and the time impact it has on complex workloads
> +or even entire systems.
> +
> +Having an accurate measure of productivity losses caused by resource
> +scarcity aids users in sizing workloads to hardware--or provisioning
> +hardware according to workload demand.
> +
> +As psi aggregates this information in realtime, systems can be managed
> +dynamically using techniques such as load shedding, migrating jobs to
> +other systems or data centers, or strategically pausing or killing low
> +priority or restartable batch jobs.
> +
> +This allows maximizing hardware utilization without sacrificing
> +workload health or risking major disruptions such as OOM kills.
> +
> +Pressure interface
> +==================
> +
> +Pressure information for each resource is exported through the
> +respective file in /proc/pressure/ -- cpu, memory, and io.
> +

Hi,

> +In both cases, the format for CPU is as such:

I don't see what "In both cases" refers to here.  It seems that you could
just remove it.

> +
> +some avg10=0.00 avg60=0.00 avg300=0.00 total=0
> +
> +and for memory and IO:
> +
> +some avg10=0.00 avg60=0.00 avg300=0.00 total=0
> +full avg10=0.00 avg60=0.00 avg300=0.00 total=0
> +
> +The "some" line indicates the share of time in which at least some
> +tasks are stalled on a given resource.


-- 
~Randy
