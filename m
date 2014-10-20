Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2B4AB6B0070
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 11:22:20 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id mc6so4171185lab.30
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 08:22:19 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id bg6si14808208lbc.42.2014.10.20.08.22.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Oct 2014 08:22:17 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/4] mm: memcontrol: remove the page_cgroup->flags field
Date: Mon, 20 Oct 2014 11:22:08 -0400
Message-Id: <1413818532-11042-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

this series gets rid of the remaining page_cgroup flags, thus cutting
the memcg per-page overhead down to one pointer.

 include/linux/page_cgroup.h |  12 ----
 mm/memcontrol.c             | 154 ++++++++++++++++++------------------------
 2 files changed, 64 insertions(+), 102 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
