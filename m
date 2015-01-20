Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 4C8646B0073
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 10:32:06 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id r20so24831698wiv.0
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 07:32:05 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id k7si33776632wjx.63.2015.01.20.07.32.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jan 2015 07:32:05 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/2] mm: memcontrol: default hierarchy interface for memory v2
Date: Tue, 20 Jan 2015 10:31:53 -0500
Message-Id: <1421767915-14232-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Andrew,

these patches changed sufficiently while in -mm that a rebase makes
sense.  The change from using "none" in the configuration files to
"max"/"infinity" requires a do-over of 1/2 and a changelog fix in 2/2.

I folded all increments, both in-tree and the ones still pending, and
credited your seq_puts() checkpatch fix, so these two changes are the
all-encompassing latest versions, and everything else can be dropped.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
