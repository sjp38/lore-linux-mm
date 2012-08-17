Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 975F46B005D
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 01:54:10 -0400 (EDT)
Message-ID: <502DDBC5.3000308@parallels.com>
Date: Fri, 17 Aug 2012 09:51:01 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 4/6] memcg: shrink dcache with memcg context
References: <1345150448-31073-1-git-send-email-yinghan@google.com>
In-Reply-To: <1345150448-31073-1-git-send-email-yinghan@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org


> diff --git a/include/linux/dcache.h b/include/linux/dcache.h
> index 094789f..624c079 100644
> --- a/include/linux/dcache.h
> +++ b/include/linux/dcache.h
> @@ -120,6 +120,10 @@ struct dentry {
>  	void *d_fsdata;			/* fs-specific data */
>  
>  	struct list_head d_lru;		/* LRU list */
> +#ifdef CONFIG_MEMCG_KMEM
> +	struct mem_cgroup *d_memcg;	/* identify per memcg lru -
> +					   NULL if not on lru */
> +#endif
>  	/*
>  	 * d_child and d_rcu can share memory
>  	 */

What I dislike the most about this approach, is the need to come up with
a pointer in the dentry structure.

I am not saying I have a better solution, though...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
