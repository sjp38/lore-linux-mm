Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 863766B00E9
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 13:20:24 -0400 (EDT)
Message-ID: <4F9AD4E7.3020302@parallels.com>
Date: Fri, 27 Apr 2012 14:18:31 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 8/9 v2] cgroup: avoid creating new cgroup under a
 cgroup being destroyed
References: <4F9A327A.6050409@jp.fujitsu.com> <4F9A36DE.30301@jp.fujitsu.com>
In-Reply-To: <4F9A36DE.30301@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Tejun Heo <tj@kernel.org>, Han Ying <yinghan@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyuki@gmail.com

On 04/27/2012 03:04 AM, KAMEZAWA Hiroyuki wrote:
> When ->pre_destroy() is called, it should be guaranteed that
> new child cgroup is not created under a cgroup, where pre_destroy()
> is running. If not, ->pre_destroy() must check children and
> return -EBUSY, which causes warning.
> 
> Signed-off-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
