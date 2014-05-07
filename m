Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2A3526B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 10:55:57 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id e49so837402eek.35
        for <linux-mm@kvack.org>; Wed, 07 May 2014 07:55:56 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u49si16613190eef.112.2014.05.07.07.55.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 07:55:55 -0700 (PDT)
Date: Wed, 7 May 2014 16:55:53 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 4/9] mm: memcontrol: catch root bypass in move precharge
Message-ID: <20140507145553.GJ9489@dhcp22.suse.cz>
References: <1398889543-23671-1-git-send-email-hannes@cmpxchg.org>
 <1398889543-23671-5-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1398889543-23671-5-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 30-04-14 16:25:38, Johannes Weiner wrote:
[...]
> @@ -6546,8 +6546,9 @@ one_by_one:
>  			cond_resched();
>  		}
>  		ret = mem_cgroup_try_charge(memcg, GFP_KERNEL, 1, false);
> +		if (ret == -EINTR)
> +			__mem_cgroup_cancel_charge(root_mem_cgroup, 1);
>  		if (ret)
> -			/* mem_cgroup_clear_mc() will do uncharge later */

I would prefer to keep the comment and explain that we will loose return
code on the way and that is why cancel on root has to be done here.

>  			return ret;
>  		mc.precharge++;
>  	}
> -- 
> 1.9.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
