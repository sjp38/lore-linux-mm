Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id C9EE96B0036
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 11:09:12 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id w62so5877707wes.5
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 08:09:12 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id bz17si7156125wib.106.2014.09.24.08.09.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Sep 2014 08:09:11 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/3] mm: memcontrol: performance fixlets for 3.18
Date: Wed, 24 Sep 2014 11:08:55 -0400
Message-Id: <1411571338-8178-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Dave Hansen <dave@sr71.net>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Andrew,

here are 2 memcg performance fixlets for 3.18.  One improves uncharge
batching to reduce expensive res_counter ops and irq-toggling, the
other one allows THP charges to succeed under cache pressure.

Thanks!

 include/linux/swap.h |   6 ++-
 mm/memcontrol.c      | 116 +++++++++++++------------------------------------
 mm/swap.c            |  27 +++++++++---
 mm/swap_state.c      |  14 ++----
 mm/vmscan.c          |   7 +--
 5 files changed, 63 insertions(+), 107 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
