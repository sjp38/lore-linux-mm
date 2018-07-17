Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 23B0F6B028E
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 10:16:33 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id a10-v6so1170239itc.9
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 07:16:33 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id w11-v6si754670ioc.155.2018.07.17.07.16.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 17 Jul 2018 07:16:31 -0700 (PDT)
Date: Tue, 17 Jul 2018 16:16:14 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 08/10] psi: pressure stall information for CPU, memory,
 and IO
Message-ID: <20180717141614.GE2494@hirez.programming.kicks-ass.net>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-9-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180712172942.10094-9-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Jul 12, 2018 at 01:29:40PM -0400, Johannes Weiner wrote:
> +/* Tracked task states */
> +enum psi_task_count {
> +	NR_RUNNING,
> +	NR_IOWAIT,
> +	NR_MEMSTALL,
> +	NR_PSI_TASK_COUNTS,
> +};

> +/* Resources that workloads could be stalled on */
> +enum psi_res {
> +	PSI_CPU,
> +	PSI_MEM,
> +	PSI_IO,
> +	NR_PSI_RESOURCES,
> +};

These two have mem and iowait in different order. It really doesn't
matter, but my brain stumbled.
