Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id AB1B96B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 07:48:38 -0400 (EDT)
Received: by mail-qa0-f42.google.com with SMTP id bv4so2948495qab.8
        for <linux-mm@kvack.org>; Wed, 31 Jul 2013 04:48:37 -0700 (PDT)
Date: Wed, 31 Jul 2013 07:48:34 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v4 0/8] memcg, cgroup: kill css_id
Message-ID: <20130731114834.GO2810@htj.dyndns.org>
References: <51F86D69.2030907@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51F86D69.2030907@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Wed, Jul 31, 2013 at 09:50:33AM +0800, Li Zefan wrote:
> This patchset converts memcg to use cgroup->id, and then we can remove
> cgroup css_id.
> 
> As we've removed memcg's own refcnt, converting memcg to use cgroup->id
> is very straight-forward.
> 
> The patchset is based on Tejun's cgroup tree.

Applied 1-3 to cgroup/for-3.12.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
