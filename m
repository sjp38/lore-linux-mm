Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 8EE7A6B00F1
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 14:18:45 -0400 (EDT)
Received: by dadq36 with SMTP id q36so1409685dad.8
        for <linux-mm@kvack.org>; Fri, 27 Apr 2012 11:18:44 -0700 (PDT)
Date: Fri, 27 Apr 2012 11:18:40 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC][PATCH 3/7 v2] res_counter: add
 res_counter_uncharge_until()
Message-ID: <20120427181840.GH26595@google.com>
References: <4F9A327A.6050409@jp.fujitsu.com>
 <4F9A343F.7020409@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F9A343F.7020409@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Glauber Costa <glommer@parallels.com>, Han Ying <yinghan@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyuki@gmail.com

On Fri, Apr 27, 2012 at 02:53:03PM +0900, KAMEZAWA Hiroyuki wrote:
> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
> index d508363..f4ec411 100644
> --- a/kernel/res_counter.c
> +++ b/kernel/res_counter.c
> @@ -66,6 +66,8 @@ done:
>  	return ret;
>  }
>  
> +
> +

Contamination?

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
