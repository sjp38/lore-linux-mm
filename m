Message-ID: <48CFA549.5010500@openvz.org>
Date: Tue, 16 Sep 2008 16:23:37 +0400
From: Pavel Emelyanov <xemul@openvz.org>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 11/9] lazy lru free vector for memcg
References: <20080911200855.94d33d3b.kamezawa.hiroyu@jp.fujitsu.com>	<20080911202249.df6026ae.kamezawa.hiroyu@jp.fujitsu.com>	<48CA9500.5060309@linux.vnet.ibm.com>	<20080916211355.277b625d.kamezawa.hiroyu@jp.fujitsu.com> <20080916211934.25c36d20.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080916211934.25c36d20.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "hugh@veritas.com" <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, menage@google.com, Dave Hansen <haveblue@us.ibm.com>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

[snip]

> @@ -938,6 +1047,7 @@ static int mem_cgroup_force_empty(struct
>  	 * So, we have to do loop here until all lists are empty.
>  	 */
>  	while (mem->res.usage > 0) {
> +		drain_page_cgroup_all();

Shouldn't we wait here till the drain process completes?

>  		if (atomic_read(&mem->css.cgroup->count) > 0)
>  			goto out;
>  		for_each_node_state(node, N_POSSIBLE)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
