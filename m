Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 86E0E828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 17:01:48 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id f206so312479546wmf.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 14:01:48 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id b6si41682505wmh.122.2016.01.13.14.01.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 14:01:47 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 0/2] mm: memcontrol: cgroup2 memory statistics
Date: Wed, 13 Jan 2016 17:01:07 -0500
Message-Id: <1452722469-24704-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Hi Andrew,

these patches add basic memory statistics so that new users of cgroup2
have some inkling of what's going on, and are not just confronted with
a single number of bytes used.

This is very short-notice, but also straight-forward. It would be cool
to get this in along with the lifting of the cgroup2 devel flag.

Michal, Vladimir, what do you think? We'll also have to figure out how
we're going to represent and break down the "kmem" consumers.

Thanks,
Johannes

 include/linux/memcontrol.h |  5 +++-
 mm/memcontrol.c            | 63 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 67 insertions(+), 1 deletion(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
