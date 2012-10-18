Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id CEA616B002B
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 04:30:28 -0400 (EDT)
Message-ID: <507FBE1B.4080906@huawei.com>
Date: Thu, 18 Oct 2012 16:30:19 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/6] memcg: make mem_cgroup_reparent_charges non failing
References: <1350480648-10905-1-git-send-email-mhocko@suse.cz> <1350480648-10905-6-git-send-email-mhocko@suse.cz>
In-Reply-To: <1350480648-10905-6-git-send-email-mhocko@suse.cz>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>

>  static int mem_cgroup_force_empty_write(struct cgroup *cont, unsigned int event)
> @@ -5013,13 +5011,9 @@ free_out:
>  static int mem_cgroup_pre_destroy(struct cgroup *cont)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> -	int ret;
>  
> -	css_get(&memcg->css);
> -	ret = mem_cgroup_reparent_charges(memcg);
> -	css_put(&memcg->css);
> -
> -	return ret;
> +	mem_cgroup_reparent_charges(memcg);
> +	return 0;
>  }
>  

Why don't you make pre_destroy() return void?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
