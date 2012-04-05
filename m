Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 041A06B004A
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 19:35:32 -0400 (EDT)
Date: Thu, 5 Apr 2012 16:35:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg: revise the position of threshold index while
 unregistering event
Message-Id: <20120405163530.a1a9c9f9.akpm@linux-foundation.org>
In-Reply-To: <1331035943-7456-1-git-send-email-handai.szj@taobao.com>
References: <1331035943-7456-1-git-send-email-handai.szj@taobao.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, kirill@shutemov.name, Sha Zhengju <handai.szj@taobao.com>

On Tue,  6 Mar 2012 20:12:23 +0800
Sha Zhengju <handai.szj@gmail.com> wrote:

> From: Sha Zhengju <handai.szj@taobao.com>
> 
> Index current_threshold should point to threshold just below or equal to usage.
> See below:
> http://www.spinics.net/lists/cgroups/msg00844.html

I have a bad feeling that I looked at a version of this patch
yesterday, but I can't find it.

> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4398,7 +4398,7 @@ static void mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
>  			continue;
>  
>  		new->entries[j] = thresholds->primary->entries[i];
> -		if (new->entries[j].threshold < usage) {
> +		if (new->entries[j].threshold <= usage) {
>  			/*
>  			 * new->current_threshold will not be used
>  			 * until rcu_assign_pointer(), so it's safe to increment

What were the runtime effects of this bug?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
