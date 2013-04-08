Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 672396B0112
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 11:52:28 -0400 (EDT)
Received: by mail-oa0-f42.google.com with SMTP id i18so6378285oag.1
        for <linux-mm@kvack.org>; Mon, 08 Apr 2013 08:51:46 -0700 (PDT)
Date: Mon, 8 Apr 2013 08:51:42 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 8/8] cgroup: kill css_id
Message-ID: <20130408155142.GF3021@htj.dyndns.org>
References: <51627DA9.7020507@huawei.com>
 <51627E8E.1010204@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51627E8E.1010204@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Mon, Apr 08, 2013 at 04:23:42PM +0800, Li Zefan wrote:
> The only user of css_id was memcg, and it has been converted to
> use cgroup->id, so kill css_id.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>

Violently-acked-by: Tejun Heo <tj@kernel.org>

Thanks a lot for killing this abomination.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
