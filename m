Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 2E8466B004F
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 17:30:39 -0500 (EST)
Date: Fri, 16 Dec 2011 14:30:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/4] memcg: clear pc->mem_cgorup if necessary.
Message-Id: <20111216143037.40a0a5b3.akpm@linux-foundation.org>
In-Reply-To: <20111214165124.4d2cf723.kamezawa.hiroyu@jp.fujitsu.com>
References: <20111214164734.4d7d6d97.kamezawa.hiroyu@jp.fujitsu.com>
	<20111214165124.4d2cf723.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>

On Wed, 14 Dec 2011 16:51:24 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> @@ -388,6 +389,10 @@ static inline void mem_cgroup_replace_page_cache(struct page *oldpage,
>  				struct page *newpage)
>  {
>  }
> +
> +static inline void mem_cgroup_reset_owner(struct page *page);
> +{
> +}
>  #endif /* CONFIG_CGROUP_MEM_CONT */
>  

Please print out Documentation/SubmitChecklist, tape it to your desk!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
