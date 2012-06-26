Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id F0EB16B005C
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 11:50:02 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 0/2] fix and deprecate use_hierarchy file
Date: Tue, 26 Jun 2012 19:47:12 +0400
Message-Id: <1340725634-9017-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>

Hi,

I am just bundling my last two patches for use_hierarchy together,
so it gets easier to track and apply.

After these patches, use_hierarchy will default to true, and will
need to be disabled at the root level to fallback to non-hierarchical.

Still need, of course, to hear Kame's opinion on this.

Thanks

Glauber Costa (2):
  fix bad behavior in use_hierarchy file
  memcg: first step towards hierarchical controller

 mm/memcontrol.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

-- 
1.7.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
