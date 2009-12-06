Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 232986B0044
	for <linux-mm@kvack.org>; Sun,  6 Dec 2009 08:30:53 -0500 (EST)
Date: Sun, 6 Dec 2009 22:30:46 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [PATCH] memcg: correct return value at mem_cgroup reclaim
Message-Id: <20091206223046.4b08cbfb.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <COL115-W58F42F7BEEB67BF8324B2A9F910@phx.gbl>
References: <COL115-W58F42F7BEEB67BF8324B2A9F910@phx.gbl>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Liu bo <bo-liu@hotmail.com>
Cc: akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

hi,

On Sun, 6 Dec 2009 18:16:14 +0800
Liu bo <bo-liu@hotmail.com> wrote:

> 
> In order to indicate reclaim has succeeded, mem_cgroup_hierarchical_reclaim() used to return 1.
> Now the return value is without indicating whether reclaim has successded usage, so just return the total reclaimed pages don't plus 1.
>  
> Signed-off-by: Liu Bo <bo-liu@hotmail.com>
> ---
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 14593f5..51b6b3c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -737,7 +737,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>    css_put(&victim->css);
>    total += ret;
>    if (mem_cgroup_check_under_limit(root_mem))
> -   return 1 + total;
> +   return total;
>   }
>   return total;
>  } 		 	   		  
What's the benefit of this change ?
I can't find any benefit to bother changing current behavior.

P.S.
You should run ./scripts/checkpatch.pl before sending your patch,
and refer to Documentation/email-clients.txt and check your email client setting.


Regards,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
