Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EB7C96B01E3
	for <linux-mm@kvack.org>; Mon, 17 May 2010 04:17:55 -0400 (EDT)
Message-ID: <4BF0FBB0.1080707@linux.intel.com>
Date: Mon, 17 May 2010 16:17:52 +0800
From: Haicheng Li <haicheng.li@linux.intel.com>
MIME-Version: 1.0
Subject: [PATCH 0/3] Fix boot_pageset sharing issue for new populated zones
 of hotadded nodes
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Wu, Fengguang" <fengguang.wu@intel.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

In our recent cpu/memory hotadd testing, with multiple nodes hotadded,
kernel easily panics under stress workload like kernel building.

The root cause is that the new populated zones of hotadded nodes are
sharing same per_cpu_pageset, i.e. boot strapping boot_pageset, which
finally causes page state wrong.

The following three patches will setup the pagesets for hotadded nodes
with dynamically allocated per_cpu_pageset struct.

---
  include/linux/memory_hotplug.h |    8 +++++
  include/linux/mmzone.h         |    2 +-
  init/main.c                    |    2 +-
  mm/memory_hotplug.c            |   27 +++++++++++-----
  mm/page_alloc.c                |   66 +++++++++++++++++++++++++++-------------
  5 files changed, 74 insertions(+), 31 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
