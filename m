Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 3B58A8D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 17:17:57 -0400 (EDT)
Date: Fri, 11 May 2012 14:17:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 1/6] memcg: fix error code in
 hugetlb_force_memcg_empty()
Message-Id: <20120511141754.e0719c26.akpm@linux-foundation.org>
In-Reply-To: <4FACDFAE.5050808@jp.fujitsu.com>
References: <4FACDED0.3020400@jp.fujitsu.com>
	<4FACDFAE.5050808@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On Fri, 11 May 2012 18:45:18 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> The conditions are handled as -EBUSY, _now_.

The changelog is poor.  I rewrote it to

: hugetlb_force_memcg_empty() incorrectly returns 0 (success) when the
: cgroup is found to be busy.  Return -EBUSY instead.

But it still doesn't tell us the end-user-visible effects of the bug. 
It should.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
