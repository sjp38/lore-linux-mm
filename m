Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id E9AA06B0035
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 18:57:58 -0400 (EDT)
Received: by mail-ee0-f49.google.com with SMTP id e53so1797509eek.22
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 15:57:58 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id q5si32330649eem.51.2014.04.30.15.57.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 15:57:57 -0700 (PDT)
Date: Wed, 30 Apr 2014 18:57:48 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 4/4] memcg: Document memory.low_limit_in_bytes
Message-ID: <20140430225748.GE26041@cmpxchg.org>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
 <1398688005-26207-5-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1398688005-26207-5-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, Apr 28, 2014 at 02:26:45PM +0200, Michal Hocko wrote:
> Describe low_limit_in_bytes and its effect.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  Documentation/cgroups/memory.txt | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index add1be001416..a52913fe96fb 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -57,6 +57,7 @@ Brief summary of control files.
>   memory.memsw.usage_in_bytes	 # show current res_counter usage for memory+Swap
>  				 (See 5.5 for details)
>   memory.limit_in_bytes		 # set/show limit of memory usage
> + memory.low_limit_in_bytes	 # set/show low limit for memory reclaim
>   memory.memsw.limit_in_bytes	 # set/show limit of memory+Swap usage
>   memory.failcnt			 # show the number of memory usage hits limits
>   memory.memsw.failcnt		 # show the number of memory+Swap hits limits
> @@ -249,6 +250,14 @@ is the objective of the reclaim. The global reclaim aims at balancing
>  zones' watermarks while the limit reclaim frees some memory to allow new
>  charges.
>  
> +Groups might be also protected from both global and limit reclaim by
> +low_limit_in_bytes knob. If the limit is non-zero the reclaim logic
> +doesn't include groups (and their subgroups - see 6. Hierarchy support)
> +which are bellow the low limit if there is other eligible cgroup in the

'below' :-) Although I really like that spello.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
