Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id A3AD56B0037
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 04:21:02 -0400 (EDT)
Message-ID: <51627DA9.7020507@huawei.com>
Date: Mon, 8 Apr 2013 16:19:53 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 0/8] memcg, cgroup: kill css_id
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

(This patchset depends on "memcg: make memcg's life cycle the same as cgroup")

This patchset converts memcg to always use cgroup->id, and then kills
css_id.

As we've removed memcg's own refcnt, converting memcg to use cgroup->id
is very straight-forward.

Li Zefan (8):
      cgroup: implement cgroup_is_ancestor()
      cgroup: implement cgroup_from_id()
      memcg: convert to use cgroup_is_ancestor()
      memcg: convert to use cgroup_from_id()
      memcg: convert to use cgroup->id
      memcg: fail to create cgroup if the cgroup id is too big
      memcg: don't use css_id any more
      cgroup: kill css_id

--
 include/linux/cgroup.h |  44 ++-------
 kernel/cgroup.c        | 302 +++++++++-----------------------------------------------------
 mm/memcontrol.c        |  53 ++++++-----
 3 files changed, 77 insertions(+), 322 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
