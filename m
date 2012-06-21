Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 553036B00FA
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 16:20:48 -0400 (EDT)
Received: by dakp5 with SMTP id p5so1703034dak.14
        for <linux-mm@kvack.org>; Thu, 21 Jun 2012 13:20:47 -0700 (PDT)
Date: Thu, 21 Jun 2012 13:20:43 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3][0/6] memcg: prevent -ENOMEM in pre_destroy()
Message-ID: <20120621202043.GD4642@google.com>
References: <4FACDED0.3020400@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FACDED0.3020400@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On Fri, May 11, 2012 at 06:41:36PM +0900, KAMEZAWA Hiroyuki wrote:
> Hi, here is v3 based on memcg-devel tree.
> git://github.com/mstsxfx/memcg-devel.git
> 
> This patch series is for avoiding -ENOMEM at calling pre_destroy() 
> which is called at rmdir(). After this patch, charges will be moved
> to root (if use_hierarchy==0) or parent (if use_hierarchy==1), and
> we'll not see -ENOMEM in rmdir() of cgroup.
> 
> v2 included some other patches than ones for handling -ENOMEM problem,
> but I divided it. I'd like to post others in different series, later.
> No logical changes in general, maybe v3 is cleaner than v2.
> 
> 0001 ....fix error code in memcg-hugetlb
> 0002 ....add res_counter_uncharge_until
> 0003 ....use res_counter_uncharge_until in memcg
> 0004 ....move charges to root is use_hierarchy==0
> 0005 ....cleanup for mem_cgroup_move_account()
> 0006 ....remove warning of res_counter_uncharge_nofail (from Costa's slub accounting series).

KAME, how is this progressing?  Is it stuck on anything?

Thank you very much.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
