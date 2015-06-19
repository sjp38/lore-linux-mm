Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 688AA6B0088
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 20:13:57 -0400 (EDT)
Received: by paceq1 with SMTP id eq1so47432070pac.3
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 17:13:57 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id a1si13379948pbu.153.2015.06.18.17.13.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jun 2015 17:13:56 -0700 (PDT)
Received: by padev16 with SMTP id ev16so71985771pad.0
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 17:13:56 -0700 (PDT)
Date: Fri, 19 Jun 2015 09:14:23 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [patch 1/3] mm, oom: organize oom context into struct
Message-ID: <20150619001423.GA5628@swordfish>
References: <alpine.DEB.2.10.1506181555350.13736@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1506181555350.13736@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello,

On (06/18/15 16:00), David Rientjes wrote:
> There are essential elements to an oom context that are passed around to
> multiple functions.
> 
> Organize these elements into a new struct, struct oom_context, that
> specifies the context for an oom condition.
> 

s/oom_context/oom_control/ ?

[..]
>  
> +struct oom_control {
> +	struct zonelist *zonelist;
> +	nodemask_t	*nodemask;
> +	gfp_t		gfp_mask;
> +	int		order;
> +	bool		force_kill;
> +};
> +
> -extern void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
> -			       int order, const nodemask_t *nodemask,
> +extern void check_panic_on_oom(struct oom_control *oc,
> +			       enum oom_constraint constraint,
>  			       struct mem_cgroup *memcg);
>  
> -extern enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
> -		unsigned long totalpages, const nodemask_t *nodemask,
> -		bool force_kill);
> +extern enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
> +		struct task_struct *task, unsigned long totalpages);
>  
> -extern bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
> -		int order, nodemask_t *mask, bool force_kill);
> +extern bool out_of_memory(struct oom_control *oc);
>  
>  extern void exit_oom_victim(void);
>  
[..]

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
