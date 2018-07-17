Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 116956B0003
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 11:32:48 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v9-v6so702402pfn.6
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 08:32:48 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d20-v6si991736pgb.682.2018.07.17.08.32.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 17 Jul 2018 08:32:47 -0700 (PDT)
Date: Tue, 17 Jul 2018 17:32:38 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 08/10] psi: pressure stall information for CPU, memory,
 and IO
Message-ID: <20180717153238.GA2476@hirez.programming.kicks-ass.net>
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
> +struct psi_group {
> +	struct psi_group_cpu *cpus;

That one wants a __percpu annotation on I think. Also, maybe a rename.

> +
> +	struct mutex stat_lock;
> +
> +	u64 some[NR_PSI_RESOURCES];
> +	u64 full[NR_PSI_RESOURCES];
> +
> +	unsigned long period_expires;
> +
> +	u64 last_some[NR_PSI_RESOURCES];
> +	u64 last_full[NR_PSI_RESOURCES];
> +
> +	unsigned long avg_some[NR_PSI_RESOURCES][3];
> +	unsigned long avg_full[NR_PSI_RESOURCES][3];
> +
> +	struct delayed_work clock_work;
> +};
