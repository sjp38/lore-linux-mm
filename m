Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id A9F386B0083
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 05:23:20 -0500 (EST)
Date: Fri, 30 Nov 2012 11:23:18 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v2 5/6] memcg: further simplify mem_cgroup_iter
Message-ID: <20121130102318.GG29317@dhcp22.suse.cz>
References: <1353955671-14385-1-git-send-email-mhocko@suse.cz>
 <1353955671-14385-6-git-send-email-mhocko@suse.cz>
 <50B87793.7000104@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50B87793.7000104@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Li Zefan <lizefan@huawei.com>

On Fri 30-11-12 13:08:35, Glauber Costa wrote:
> On 11/26/2012 10:47 PM, Michal Hocko wrote:
> > The code would be much more easier to follow if we move the iteration
> > outside of the function (to __mem_cgrou_iter_next) so the distinction
> > is more clear.
> totally nit: Why is it call __mem_cgrou ?
> 
> What happened to your p ?

It was a fight against p as a source of all evil but the fight is over
and we can put it back :p 

Thanks for noticing
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
