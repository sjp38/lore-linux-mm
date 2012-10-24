Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id B26BE6B0070
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 05:41:57 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 0/2 V2] memory_hotplug: fix memory hotplug bug
Date: Wed, 24 Oct 2012 17:43:50 +0800
Message-Id: <1351071840-5060-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, Kay Sievers <kay.sievers@vrfy.org>, Greg Kroah-Hartman <gregkh@suse.de>, Mel Gorman <mgorman@suse.de>, 'FNST-Wen Congyang' <wency@cn.fujitsu.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org

We found 2 bugs while we test and develop memory hotplug.

The hotplug code does not handle node_states[N_NORMAL_MEMORY] correctly,
it may corrupt the memory.

And we ensure the SLUB do NOT respond when node_states[N_NORMAL_MEMORY]
is not changed.

The patchset is based on mainline(3d0ceac129f3ea0b125289055a3aa7519d38df77)


CC: David Rientjes <rientjes@google.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
CC: Rob Landley <rob@landley.net>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Jiang Liu <jiang.liu@huawei.com>
CC: Kay Sievers <kay.sievers@vrfy.org>
CC: Greg Kroah-Hartman <gregkh@suse.de>
CC: Mel Gorman <mgorman@suse.de>
CC: 'FNST-Wen Congyang' <wency@cn.fujitsu.com>
CC: linux-doc@vger.kernel.org
CC: linux-kernel@vger.kernel.org
CC: linux-mm@kvack.org

Lai Jiangshan (2):
  memory_hotplug: fix possible incorrect node_states[N_NORMAL_MEMORY]
  slub, hotplug: ignore unrelated node's hot-adding and hot-removing

 Documentation/memory-hotplug.txt |    5 +-
 include/linux/memory.h           |    1 +
 mm/memory_hotplug.c              |  136 +++++++++++++++++++++++++++++++++-----
 mm/slub.c                        |    4 +-
 4 files changed, 127 insertions(+), 19 deletions(-)

-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
