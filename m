Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9B74C82F66
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 18:03:03 -0400 (EDT)
Received: by qgt47 with SMTP id 47so162731134qgt.2
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 15:03:03 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 64si25161647qkq.118.2015.10.05.15.03.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Oct 2015 15:03:03 -0700 (PDT)
Date: Mon, 5 Oct 2015 15:03:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg: convert threshold to bytes
Message-Id: <20151005150301.44e6ba05be5f602f3335a7ee@linux-foundation.org>
In-Reply-To: <fc100a5a381d1961c3b917489eb82b098d9e0840.1444081366.git.shli@fb.com>
References: <fc100a5a381d1961c3b917489eb82b098d9e0840.1444081366.git.shli@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Mon, 5 Oct 2015 14:44:22 -0700 Shaohua Li <shli@fb.com> wrote:

> The page_counter_memparse() returns pages for the threshold, while
> mem_cgroup_usage() returns bytes for memory usage. Convert the threshold
> to bytes.
> 
> Looks a regression introduced by 3e32cb2e0a12b69150

That was two years ago.  Why hasn't anyone noticed before now?

> ...
>
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3387,6 +3387,7 @@ static int __mem_cgroup_usage_register_event(struct mem_cgroup *memcg,
>  	ret = page_counter_memparse(args, "-1", &threshold);
>  	if (ret)
>  		return ret;
> +	threshold <<= PAGE_SHIFT;
>  
>  	mutex_lock(&memcg->thresholds_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
