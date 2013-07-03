Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id F0CF46B0036
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 14:28:33 -0400 (EDT)
Date: Wed, 3 Jul 2013 20:27:48 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 09/13] sched: Favour moving tasks towards nodes that
 incurred more faults
Message-ID: <20130703182748.GA18898@dyad.programming.kicks-ass.net>
References: <1372861300-9973-1-git-send-email-mgorman@suse.de>
 <1372861300-9973-10-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1372861300-9973-10-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 03, 2013 at 03:21:36PM +0100, Mel Gorman wrote:
>  static bool migrate_improves_locality(struct task_struct *p, struct lb_env *env)
>  {

> +	if (p->numa_faults[task_faults_idx(dst_nid, 1)] >
> +	    p->numa_faults[task_faults_idx(src_nid, 1)])
> +		return true;

> +}

> +static bool migrate_degrades_locality(struct task_struct *p, struct lb_env *env)
> +{

> +	if (p->numa_faults[src_nid] > p->numa_faults[dst_nid])
>  		return true;

I bet you wanted to use task_faults_idx() there too ;-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
