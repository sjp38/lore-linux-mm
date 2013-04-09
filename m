Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 4D71E6B0006
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 02:49:06 -0400 (EDT)
Date: Tue, 9 Apr 2013 08:49:04 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 5/8] memcg: convert to use cgroup->id
Message-ID: <20130409064904.GD29860@dhcp22.suse.cz>
References: <51627DA9.7020507@huawei.com>
 <51627E33.4090107@huawei.com>
 <20130408145702.GM17178@dhcp22.suse.cz>
 <516384BC.7040302@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <516384BC.7040302@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Tue 09-04-13 11:02:20, Li Zefan wrote:
> On 2013/4/8 22:57, Michal Hocko wrote:
> > On Mon 08-04-13 16:22:11, Li Zefan wrote:
> >> This is a preparation to kill css_id.
> >>
> >> Signed-off-by: Li Zefan <lizefan@huawei.com>
> > 
> > This patch depends on the following patch, doesn't it? There is no
> > guarantee that id fits into short right now. Not such a big deal but
> > would be nicer to have that guarantee for bisectability.
> > 
> 
> Not necessary, because css_id still prevents us from creating too
> many cgroups.

Right you are.

Thanks
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
