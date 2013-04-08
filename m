Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 609006B0037
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 03:18:15 -0400 (EDT)
Message-ID: <51626F50.6090204@parallels.com>
Date: Mon, 8 Apr 2013 11:18:40 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/7] memcg: make memcg's life cycle the same as cgroup
References: <515BF233.6070308@huawei.com> <516131D7.8030004@huawei.com>
In-Reply-To: <516131D7.8030004@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, Tejun Heo <tj@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On 04/07/2013 12:44 PM, Li Zefan wrote:
> Hi,
> 
> I'm rebasing this patchset against latest linux-next, and it conflicts with
> "[PATCH v2] memcg: debugging facility to access dangling memcgs." slightly.
> 
> That is a debugging patch and will never be pushed into mainline, so should I
> still base this patchset on that debugging patch?
> 
It will conflict as well with my shrinking patches: I will still keep
the memcgs in the dangling list, but that will have nothing to do with
debugging. So I will split that patch in a list management part, which
will be used, and a debugging part (with the file + the debugging
information).

I will be happy to rebase it ontop of your series.

> Also that patch needs update (and can be simplified) after this patchset:
> - move memcg_dangling_add() to mem_cgroup_css_offline()
> - remove memcg->memcg_name, and use cgroup_path() in mem_cgroup_dangling_read()?
> 

Don't worry about it. If this is just this one patch conflicting, I
would avise Andrew to remove it, and I will provide another (maybe two,
already splitted up) version.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
