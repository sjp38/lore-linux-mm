Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 8E0096B0032
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 07:49:06 -0400 (EDT)
Received: by mail-qe0-f47.google.com with SMTP id b10so297496qen.34
        for <linux-mm@kvack.org>; Wed, 31 Jul 2013 04:49:05 -0700 (PDT)
Date: Wed, 31 Jul 2013 07:49:02 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v4 8/8] cgroup: kill css_id
Message-ID: <20130731114902.GP2810@htj.dyndns.org>
References: <51F86D69.2030907@huawei.com>
 <51F86DFC.9060301@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51F86DFC.9060301@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Wed, Jul 31, 2013 at 09:53:00AM +0800, Li Zefan wrote:
> The only user of css_id was memcg, and it has been convered to use
> cgroup->id, so kill css_id.
> 
> Signed-off-by: Li Zefan <lizefan@huwei.com>
> Reviewed-by: Michal Hocko <mhocko@suse.cz>

Violently-acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
