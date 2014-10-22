Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id E5E176B0069
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 14:29:37 -0400 (EDT)
Received: by mail-la0-f53.google.com with SMTP id gq15so3404151lab.26
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 11:29:37 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id k3si24441341lbd.26.2014.10.22.11.29.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Oct 2014 11:29:36 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/2] mm: memcontrol: fix race between migration and writeback
Date: Wed, 22 Oct 2014 14:29:26 -0400
Message-Id: <1414002568-21042-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

This is fall-out from the memcg lifetime rework in 3.17, where
writeback statistics can get lost against a migrating page.

The (-stable) fix is adapting the page stat side to the new lifetime
rules, rather than making an exception specifically for them, which
seems less error prone and generally the right way forward.

 include/linux/memcontrol.h | 58 ++++++++++++++--------------------------------
 include/linux/mm.h         |  1 -
 mm/memcontrol.c            | 54 ++++++++++++++++++------------------------
 mm/page-writeback.c        | 43 ++++++++++++----------------------
 mm/rmap.c                  | 20 ++++++++--------
 5 files changed, 64 insertions(+), 112 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
