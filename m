Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id E375D6B0044
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 03:40:21 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id rq2so1138433pbb.14
        for <linux-mm@kvack.org>; Wed, 07 Nov 2012 00:40:21 -0800 (PST)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH V2 0/2] Provide more precise dump info for memcg-oom
Date: Wed,  7 Nov 2012 16:40:02 +0800
Message-Id: <1352277602-21687-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org, mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, rientjes@google.com
Cc: linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>


When memcg oom is happening the current memcg related dump information
is limited for debugging. The patches provide more detailed memcg page statistics
and also take hierarchy into consideration.
The previous primitive version can be reached here: https://lkml.org/lkml/2012/7/30/179.

Change log:
	1. some modification towards hierarchy
	2. rework dump_tasks
	3. rebased on Michal's mm tree since-3.6  

Any comments are welcomed. : )


Sha Zhengju (2):
	memcg-oom-provide-more-precise-dump-info-while-memcg.patch
	oom-rework-dump_tasks-to-optimize-memcg-oom-situatio.patch

 include/linux/memcontrol.h |    7 ++++
 include/linux/oom.h        |    2 +
 mm/memcontrol.c            |   85 +++++++++++++++++++++++++++++++++++++++-----
 mm/oom_kill.c              |   61 +++++++++++++++++++------------
 4 files changed, 122 insertions(+), 33 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
