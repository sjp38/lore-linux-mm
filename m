Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4F7C26B0038
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 07:34:31 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id rd3so51917702pab.3
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 04:34:31 -0800 (PST)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id b1si13624482pat.116.2015.01.30.04.34.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 Jan 2015 04:34:30 -0800 (PST)
Received: by mail-pa0-f51.google.com with SMTP id fb1so52073109pad.10
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 04:34:30 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v2 0/4] enhance compaction success rate
Date: Fri, 30 Jan 2015 21:34:08 +0900
Message-Id: <1422621252-29859-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

This patchset aims at increase of compaction success rate. Changes are 
related to compaction finish condition and freepage isolation condition.

>From these changes, I did stress highalloc test in mmtests with nonmovable
order 7 allocation configuration, and compaction success rate (%) are

Base	Patch-1 Patch-2 Patch-3	Patch-4
18.47	27.13   31.82	--	42.20

Note: Base version is tested in v1 and the others are tested freshly.
Test is perform based on next-20150103 and Vlastimil's stealing logic
patches due to current next's unstablility.
Patch-3 isn't tested since there is no functional change.

Joonsoo (3):
  mm/compaction: stop the isolation when we isolate enough freepage
  mm/page_alloc: separate steal decision from steal behaviour part
  mm/compaction: enhance compaction finish condition

Joonsoo Kim (1):
  mm/compaction: fix wrong order check in compact_finished()

 include/linux/mmzone.h |  3 +++
 mm/compaction.c        | 47 ++++++++++++++++++++++++++++++++++++++---------
 mm/internal.h          |  1 +
 mm/page_alloc.c        | 50 ++++++++++++++++++++++++++++++++------------------
 4 files changed, 74 insertions(+), 27 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
