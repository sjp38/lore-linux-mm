Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 8D9896B00F7
	for <linux-mm@kvack.org>; Mon, 14 May 2012 14:17:30 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so9277853pbb.14
        for <linux-mm@kvack.org>; Mon, 14 May 2012 11:17:29 -0700 (PDT)
Date: Mon, 14 May 2012 11:17:25 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/6] add res_counter_uncharge_until()
Message-ID: <20120514181725.GF2366@google.com>
References: <4FACDED0.3020400@jp.fujitsu.com>
 <4FACE01A.4040405@jp.fujitsu.com>
 <20120511141945.c487e94c.akpm@linux-foundation.org>
 <4FB05B8F.8020408@jp.fujitsu.com>
 <CAFTL4hwGEhyxZO0sXx5gVyK_xjhMQEbHojJbHzQmVKafNyVWtw@mail.gmail.com>
 <4FB0DF4A.5010506@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FB0DF4A.5010506@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Frederic Weisbecker <fweisbec@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On Mon, May 14, 2012 at 07:32:42PM +0900, KAMEZAWA Hiroyuki wrote:
> [PATCH 2/6] memcg: add res_counter_uncharge_until()
> 
> From: Frederic Weisbecker <fweisbec@gmail.com>
> 
> At killing res_counter which is a child of other counter,
> we need to do
> 	res_counter_uncharge(child, xxx)
> 	res_counter_charge(parent, xxx)
> 
> This is not atomic and wasting cpu. This patch adds
> res_counter_uncharge_until(). This function's uncharge propagates
> to ancestors until specified res_counter.
> 
> 	res_counter_uncharge_until(child, parent, xxx)
> 
> Now, ops is atomic and efficient.
> 
> Changelog since v2
>  - removed unnecessary lines.
>  - added 'From' , this patch comes from his one.
> 
> Signed-off-by: Frederic Weisbecker <fweisbec@gmail.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
