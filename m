Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id D835C6B0081
	for <linux-mm@kvack.org>; Mon, 14 May 2012 16:09:30 -0400 (EDT)
Received: by dakp5 with SMTP id p5so9208235dak.14
        for <linux-mm@kvack.org>; Mon, 14 May 2012 13:09:30 -0700 (PDT)
Date: Mon, 14 May 2012 13:09:25 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 6/6] remove __must_check for
 res_counter_charge_nofail()
Message-ID: <20120514200925.GH2366@google.com>
References: <4FACDED0.3020400@jp.fujitsu.com>
 <4FACE184.6020307@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FACE184.6020307@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On Fri, May 11, 2012 at 06:53:08PM +0900, KAMEZAWA Hiroyuki wrote:
> I picked this up from Costa's slub memcg series. For fixing added warning
> by patch 4.
> ==
> From: Glauber Costa <glommer@parallels.com>
> Subject: [PATCH 6/6] remove __must_check for res_counter_charge_nofail()
> 
> Since we will succeed with the allocation no matter what, there
> isn't the need to use __must_check with it. It can very well
> be optional.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

For 3-6,

 Reviewed-by: Tejun Heo <tj@kernel.org>

Thanks a lot for doing this.  This doesn't solve all the failure paths
tho.  ie. what about -EINTR failures from lock contention?
pre_destroy() would probably need delay and retry logic with
WARN_ON_ONCE() on !-EINTR failures.

Thank you.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
