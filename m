Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id CAA266B0023
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 04:59:06 -0500 (EST)
Message-ID: <51079D7C.8030400@parallels.com>
Date: Tue, 29 Jan 2013 13:59:24 +0400
From: Lord Glauber Costa of Sealand <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 6/6] memcg: init/free swap cgroup strucutres upon create/free
 child memcg
References: <510658FC.50009@oracle.com>
In-Reply-To: <510658FC.50009@oracle.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org

On 01/28/2013 02:54 PM, Jeff Liu wrote:
>  static void free_rcu(struct rcu_head *rcu_head)
> @@ -6116,6 +6117,8 @@ mem_cgroup_css_alloc(struct cgroup *cont)
>  			INIT_WORK(&stock->work, drain_local_stock);
>  		}
>  	} else {
> +		if (swap_cgroup_init())
> +			goto free_out;
>  		parent = mem_cgroup_from_cont(cont->parent);
>  		memcg->use_hierarchy = parent->use_hierarchy;
>  		memcg->oom_kill_disable = parent->oom_kill_disable;
Be aware that this will conflict with latest -mm where those were moved
to css_online().


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
