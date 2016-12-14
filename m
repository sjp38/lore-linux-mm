Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 33EC56B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 09:53:34 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id bk3so10853379wjc.4
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 06:53:34 -0800 (PST)
Received: from mail-wj0-f194.google.com (mail-wj0-f194.google.com. [209.85.210.194])
        by mx.google.com with ESMTPS id 5si54571626wje.84.2016.12.14.06.53.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 06:53:32 -0800 (PST)
Received: by mail-wj0-f194.google.com with SMTP id xy5so5207197wjc.1
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 06:53:32 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/3] mm, oom: add oom detection tracepoints
Date: Wed, 14 Dec 2016 15:53:21 +0100
Message-Id: <20161214145324.26261-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
this is a long overdue and I am really sorry about that. I just didn't
get to sit and come up with this earlier as there was always some
going on which preempted it. This patchset adds two tracepoints which
should help us to debug oom decision making. The first one is placed
in should_reclaim_retry and it tells us why do we keep retrying the
allocation and reclaim while the second is in should_compact_retry which
tells us the similar for the high order requests.

In combination with the existing compaction and reclaim tracepoints we
can draw a much better picture about what is going on and why we go
and declare the oom.

I am not really a tracepoint guy so I hope I didn't do anything
obviously stupid there. Thanks to Vlastimil for his help before I've
posted this.

Anywa feedback is of course welcome!
Michal Hocko (3):
      mm, trace: extract COMPACTION_STATUS and ZONE_TYPE to a common header
      oom, trace: Add oom detection tracepoints
      oom, trace: add compaction retry tracepoint

 include/trace/events/compaction.h | 56 ------------------------
 include/trace/events/mmflags.h    | 90 +++++++++++++++++++++++++++++++++++++++
 include/trace/events/oom.h        | 81 +++++++++++++++++++++++++++++++++++
 mm/page_alloc.c                   | 32 ++++++++++----
 4 files changed, 195 insertions(+), 64 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
