Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id CB4526B00EF
	for <linux-mm@kvack.org>; Fri, 25 May 2012 05:34:33 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v7 0/2] fixes for sock memcg static branch disablement
Date: Fri, 25 May 2012 13:32:06 +0400
Message-Id: <1337938328-11537-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, David Miller <davem@davemloft.net>

Hi Andrew,

I believe this one addresses all of your previous comments.

Besides merging your patch, I tried to improve the comments so they would
be more informative. 

The first patch, I believe, is already merged at your tree. But I am including
it here for completeness. I had no changes since last submission, so feel free
to pick the second - or if there are still missing changes you'd like to see,
point me to them.

Thanks

Glauber Costa (2):
  Always free struct memcg through schedule_work()
  decrement static keys on real destroy time

 include/net/sock.h        |   22 ++++++++++++++++++
 mm/memcontrol.c           |   55 ++++++++++++++++++++++++++++++++++----------
 net/ipv4/tcp_memcontrol.c |   34 ++++++++++++++++++++++-----
 3 files changed, 91 insertions(+), 20 deletions(-)

-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
