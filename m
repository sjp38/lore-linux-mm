Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 5B1CB6B0068
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 14:32:34 -0400 (EDT)
Message-ID: <4FEDF49A.9020907@redhat.com>
Date: Fri, 29 Jun 2012 14:31:54 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 15/40] autonuma: knuma_migrated per NUMA node queues
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com> <1340888180-15355-16-git-send-email-aarcange@redhat.com>
In-Reply-To: <1340888180-15355-16-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 06/28/2012 08:55 AM, Andrea Arcangeli wrote:

> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 2427706..d53b26a 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -697,6 +697,12 @@ typedef struct pglist_data {
>   	struct task_struct *kswapd;
>   	int kswapd_max_order;
>   	enum zone_type classzone_idx;
> +#ifdef CONFIG_AUTONUMA
> +	spinlock_t autonuma_lock;
> +	struct list_head autonuma_migrate_head[MAX_NUMNODES];
> +	unsigned long autonuma_nr_migrate_pages;
> +	wait_queue_head_t autonuma_knuma_migrated_wait;
> +#endif
>   } pg_data_t;
>
>   #define node_present_pages(nid)	(NODE_DATA(nid)->node_present_pages)

Once again, the data structure could use documentation.

What are these things for?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
