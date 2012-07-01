Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id A77EB6B00CB
	for <linux-mm@kvack.org>; Sun,  1 Jul 2012 12:58:21 -0400 (EDT)
Message-ID: <4FF08185.4050806@redhat.com>
Date: Sun, 01 Jul 2012 12:57:41 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 23/40] autonuma: sched_set_autonuma_need_balance
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com> <1340888180-15355-24-git-send-email-aarcange@redhat.com>
In-Reply-To: <1340888180-15355-24-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 06/28/2012 08:56 AM, Andrea Arcangeli wrote:
> Invoke autonuma_balance only on the busy CPUs at the same frequency of
> the CFS load balance.
>
> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>
> ---
>   kernel/sched/fair.c |    3 +++
>   1 files changed, 3 insertions(+), 0 deletions(-)
>
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index dab9bdd..ff288c0 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -4906,6 +4906,9 @@ static void run_rebalance_domains(struct softirq_action *h)
>
>   	rebalance_domains(this_cpu, idle);
>
> +	if (!this_rq->idle_balance)
> +		sched_set_autonuma_need_balance();
> +

Misleading function name in patch 13, this actually calls
sched_autonuma_balance and is not setting a flag like the
name suggests (to me).

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
