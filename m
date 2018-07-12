Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 805D46B0007
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 16:08:25 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id r144-v6so18729801ywg.9
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 13:08:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a14-v6sor6577289ybr.71.2018.07.12.13.08.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Jul 2018 13:08:24 -0700 (PDT)
Date: Thu, 12 Jul 2018 13:08:21 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 09/10] psi: cgroup support
Message-ID: <20180712200821.GN72677@devbig577.frc2.facebook.com>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-10-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180712172942.10094-10-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Jul 12, 2018 at 01:29:41PM -0400, Johannes Weiner wrote:
> On a system that executes multiple cgrouped jobs and independent
> workloads, we don't just care about the health of the overall system,
> but also that of individual jobs, so that we can ensure individual job
> health, fairness between jobs, or prioritize some jobs over others.
> 
> This patch implements pressure stall tracking for cgroups. In kernels
> with CONFIG_PSI=y, cgroup2 groups will have cpu.pressure,
> memory.pressure, and io.pressure files that track aggregate pressure
> stall times for only the tasks inside the cgroup.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Tejun Heo <tj@kernel.org>

Please feel free to route with the rest of the patchset.

Thanks.

-- 
tejun
