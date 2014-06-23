Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 599A96B0037
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 05:14:23 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id r20so3766320wiv.14
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 02:14:22 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lp7si22309773wjb.116.2014.06.23.02.14.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Jun 2014 02:14:21 -0700 (PDT)
Date: Mon, 23 Jun 2014 11:14:18 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: remove lookup_cgroup_page() prototype
Message-ID: <20140623091418.GE9743@dhcp22.suse.cz>
References: <1403217136-4863-1-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1403217136-4863-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 19-06-14 15:32:16, Greg Thelen wrote:
> 6b208e3f6e35 ("mm: memcg: remove unused node/section info from
> pc->flags") deleted the lookup_cgroup_page() function but left a
> prototype for it.
> 
> Kill the vestigial prototype.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/page_cgroup.h | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 777a524716db..0ff470de3c12 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -42,7 +42,6 @@ static inline void __init page_cgroup_init(void)
>  #endif
>  
>  struct page_cgroup *lookup_page_cgroup(struct page *page);
> -struct page *lookup_cgroup_page(struct page_cgroup *pc);
>  
>  #define TESTPCGFLAG(uname, lname)			\
>  static inline int PageCgroup##uname(struct page_cgroup *pc)	\
> -- 
> 2.0.0.526.g5318336
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
