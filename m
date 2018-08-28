Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2F7A66B4807
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 16:56:32 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id d23-v6so1313241ywb.2
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 13:56:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u14-v6sor503505ybp.166.2018.08.28.13.56.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Aug 2018 13:56:28 -0700 (PDT)
Date: Tue, 28 Aug 2018 16:56:25 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 8/9] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180828205625.GA14030@cmpxchg.org>
References: <20180828172258.3185-1-hannes@cmpxchg.org>
 <20180828172258.3185-9-hannes@cmpxchg.org>
 <6ff71c29-3b6a-4849-6f2a-3d829bbd43e2@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6ff71c29-3b6a-4849-6f2a-3d829bbd43e2@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Peter Enderborg <peter.enderborg@sony.com>, Shakeel Butt <shakeelb@google.com>, Mike Galbraith <efault@gmx.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Aug 28, 2018 at 01:11:11PM -0700, Randy Dunlap wrote:
> On 08/28/2018 10:22 AM, Johannes Weiner wrote:
> > diff --git a/Documentation/accounting/psi.txt b/Documentation/accounting/psi.txt
> > new file mode 100644
> > index 000000000000..51e7ef14142e
> > --- /dev/null
> > +++ b/Documentation/accounting/psi.txt
> > @@ -0,0 +1,64 @@
> > +================================
> > +PSI - Pressure Stall Information
> > +================================
> > +
> > +:Date: April, 2018
> > +:Author: Johannes Weiner <hannes@cmpxchg.org>
> > +
> > +When CPU, memory or IO devices are contended, workloads experience
> > +latency spikes, throughput losses, and run the risk of OOM kills.
> > +
> > +Without an accurate measure of such contention, users are forced to
> > +either play it safe and under-utilize their hardware resources, or
> > +roll the dice and frequently suffer the disruptions resulting from
> > +excessive overcommit.
> > +
> > +The psi feature identifies and quantifies the disruptions caused by
> > +such resource crunches and the time impact it has on complex workloads
> > +or even entire systems.
> > +
> > +Having an accurate measure of productivity losses caused by resource
> > +scarcity aids users in sizing workloads to hardware--or provisioning
> > +hardware according to workload demand.
> > +
> > +As psi aggregates this information in realtime, systems can be managed
> > +dynamically using techniques such as load shedding, migrating jobs to
> > +other systems or data centers, or strategically pausing or killing low
> > +priority or restartable batch jobs.
> > +
> > +This allows maximizing hardware utilization without sacrificing
> > +workload health or risking major disruptions such as OOM kills.
> > +
> > +Pressure interface
> > +==================
> > +
> > +Pressure information for each resource is exported through the
> > +respective file in /proc/pressure/ -- cpu, memory, and io.
> > +
> 
> Hi,
> 
> > +In both cases, the format for CPU is as such:
> 
> I don't see what "In both cases" refers to here.  It seems that you could
> just remove it.

You're right, that must be a left-over from when I described CPU
separately; "both cases" referred to memory and IO which have
identical formats. It needs to be removed:

diff --git a/Documentation/accounting/psi.txt b/Documentation/accounting/psi.txt
index e051810d5127..b8ca28b60215 100644
--- a/Documentation/accounting/psi.txt
+++ b/Documentation/accounting/psi.txt
@@ -35,7 +35,7 @@ Pressure interface
 Pressure information for each resource is exported through the
 respective file in /proc/pressure/ -- cpu, memory, and io.
 
-In both cases, the format for CPU is as such:
+The format for CPU is as such:
 
 some avg10=0.00 avg60=0.00 avg300=0.00 total=0
 
