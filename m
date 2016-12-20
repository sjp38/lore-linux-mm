Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 96A706B02F5
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 08:01:44 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id gl16so1651121wjc.5
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 05:01:44 -0800 (PST)
Received: from mail-wj0-f196.google.com (mail-wj0-f196.google.com. [209.85.210.196])
        by mx.google.com with ESMTPS id l6si18894815wmd.112.2016.12.20.05.01.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 05:01:43 -0800 (PST)
Received: by mail-wj0-f196.google.com with SMTP id j10so27573730wjb.3
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 05:01:43 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/3 v2] mm, oom: add oom detection tracepoints 
Date: Tue, 20 Dec 2016 14:01:32 +0100
Message-Id: <20161220130135.15719-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
the previous version of the patchset has been posted here [1]. kbuild
robot found some compilation issues which are fixed here. Vlastimil
has reviewed the patchset and his review feedback has been addressed I
believe. No other changes were introduced in this version and I believe
this should be ready to be merged.

Original cover:
This is a long overdue and I am really sorry about that. I just didn't
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

[1] http://lkml.kernel.org/r/20161214145324.26261-1-mhocko@kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
