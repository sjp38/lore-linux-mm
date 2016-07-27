Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2BC9B6B0260
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 10:44:35 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id o124so3960977pfg.1
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 07:44:35 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id e2si6783253pfk.26.2016.07.27.07.44.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 07:44:34 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id h186so1960816pfg.2
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 07:44:34 -0700 (PDT)
Date: Wed, 27 Jul 2016 10:43:07 -0400
From: Janani Ravichandran <janani.rvchndrn@gmail.com>
Subject: [PATCH 0/2] New tracepoints for slowpath and memory compaction
Message-ID: <cover.1469629027.git.janani.rvchndrn@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: riel@surriel.com, akpm@linux-foundation.org, hannes@compxchg.org, vdavydov@virtuozzo.com, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com, rostedt@goodmis.org

Hi,

I am an Outreachy intern working under Rik van Riel on memory allocation 
latency tracing using tracepoints.
The goal of my project is to add tracepoints to code in vmscan.c and 
compaction.c to gain insight into what happens there and examine latencies
using a postprocessing script.

The one here:

https://github.com/Jananiravichandran/Analyzing-tracepoints/blob/master/shrink_slab_latencies.py

is a very basic script that shows how long direct reclaim and shrinkers take.
I intend to keep updating the script as more tracepoints are added in
the direct reclaim and compaction code and eventually submit the script
itself once I'm done.
Suggestions on this are most welcome! 

As of now, there are no mechanisms to find out how long slowpath and
memory compaction take to execute. This patchset adds new tracepoints 
and also modifies a couple of existing ones to address this and collect
some zone information that may be useful.

Janani Ravichandran (2):
  mm: page_alloc.c: Add tracepoints for slowpath
  mm: compaction.c: Add/Modify direct compaction tracepoints

 include/trace/events/compaction.h | 38 ++++++++++++++++++++++++++++++++-----
 include/trace/events/kmem.h       | 40 +++++++++++++++++++++++++++++++++++++++
 mm/compaction.c                   |  6 ++++--
 mm/page_alloc.c                   |  5 +++++
 4 files changed, 82 insertions(+), 7 deletions(-)

-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
