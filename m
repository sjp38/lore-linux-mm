Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8CA8F6B0035
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 08:18:26 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id q58so638085wes.35
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 05:18:23 -0700 (PDT)
Received: from mail-we0-x234.google.com (mail-we0-x234.google.com [2a00:1450:400c:c03::234])
        by mx.google.com with ESMTPS id o2si7088545wjx.31.2014.09.12.05.18.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 12 Sep 2014 05:18:22 -0700 (PDT)
Received: by mail-we0-f180.google.com with SMTP id t60so657945wes.11
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 05:18:22 -0700 (PDT)
Date: Fri, 12 Sep 2014 14:18:17 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] oom: break after selecting process to kill
Message-ID: <20140912121817.GE12156@dhcp22.suse.cz>
References: <20140911213338.GA4098@localhost.localdomain>
 <20140912080853.GA12156@dhcp22.suse.cz>
 <20140912082329.GA12330@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140912082329.GA12330@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Niv Yehezkel <executerx@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, oleg@redhat.com

On Fri 12-09-14 04:23:29, Niv Yehezkel wrote:
[...]
> From 1e92f232e9367565d93629b54117b27b9bbfebda Mon Sep 17 00:00:00 2001
> From: Niv Yehezkel <executerx@gmail.com>
> Date: Fri, 12 Sep 2014 04:21:48 -0400
> Subject: [PATCH] break after selecting process to kill
> 
> 

Now the justification please ;)

> Signed-off-by: Niv Yehezkel <executerx@gmail.com>
> ---
>  mm/oom_kill.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 1e11df8..3203578 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -315,7 +315,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  		case OOM_SCAN_SELECT:
>  			chosen = p;
>  			chosen_points = ULONG_MAX;
> -			/* fall through */
> +			break;
>  		case OOM_SCAN_CONTINUE:
>  			continue;
>  		case OOM_SCAN_ABORT:
> @@ -324,6 +324,8 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  		case OOM_SCAN_OK:
>  			break;
>  		};
> +		if (chosen_points == ULONG_MAX)
> +			break;
>  		points = oom_badness(p, NULL, nodemask, totalpages);
>  		if (!points || points < chosen_points)
>  			continue;
> -- 
> 1.7.10.4
> 


-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
