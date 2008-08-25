Date: Tue, 26 Aug 2008 08:31:02 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 2/2] quicklist shouldn't be proportional to # of CPUs
In-Reply-To: <48B2FC9D.3020300@sgi.com>
References: <20080821.001322.236658980.davem@davemloft.net> <48B2FC9D.3020300@sgi.com>
Message-Id: <20080826082756.232C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: kosaki.motohiro@jp.fujitsu.com, David Miller <davem@davemloft.net>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org, tokunaga.keiich@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Hi Mike, 

> >>> +	num_cpus_per_node = cpus_weight_nr(node_to_cpumask(node));
> 
> I think the more correct usage would be:
> 
> 	{
> 		node_to_cpumask_ptr(v, node);
> 		num_cpus_per_node = cpus_weight_nr(*v);
> 		max /= num_cpus_per_node;
> 
> 		return max(max, min_pages);
> 	}
> 
> which should load 'v' with a pointer to the node_to_cpumask_map[node] entry
> [and avoid using stack space for the cpumask_t variable for those arch's
> that define a node_to_cpumask_map (or similar).]  Otherwise a local cpumask_t
> variable '_v' is created to which 'v' is pointing to and thus can be used
> directly as an arg to the cpu_xxx ops.

Thank you for your attension.
please see my latest patch (http://marc.info/?l=linux-mm&m=121966459713193&w=2)
it do that.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
