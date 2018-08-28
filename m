Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 268C66B472E
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 13:19:59 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id q3-v6so1915395qki.4
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 10:19:59 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id m34-v6si1557554qkh.283.2018.08.28.10.19.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 10:19:58 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH 0/2] fs/dcache: Track # of negative dentries
Date: Tue, 28 Aug 2018 13:19:38 -0400
Message-Id: <1535476780-5773-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>, Waiman Long <longman@redhat.com>

This patchset is a reduced scope version of the
patchset "fs/dcache: Track & limit # of negative dentries"
(https://lkml.org/lkml/2018/7/12/586). Only the first 2 patches are
included to track the number of negative dentries in the system as well
as making negative dentries more easily reclaimed than positive ones.

There are controversies on limiting number of negative dentries as it may
make negative dentries special in term of how memory resources are to
be managed in the kernel. However, I don't believe I heard any concern
about tracking the number of negative dentries in the system. So it is
better to separate that out and get it done with. We can deal with the
controversial part later on.

Patch 1 adds tracking to the number of negative dentries in the LRU list.

Patch 2 makes negative dentries to be added at the head end of the LRU
list so that they are first to go when a shrinker is running if those
negative dentries are never referenced again.

Waiman Long (2):
  fs/dcache: Track & report number of negative dentries
  fs/dcache: Make negative dentries easier to be reclaimed

 Documentation/sysctl/fs.txt | 19 ++++++++++-----
 fs/dcache.c                 | 56 ++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/dcache.h      |  8 ++++---
 include/linux/list_lru.h    | 17 ++++++++++++++
 mm/list_lru.c               | 16 +++++++++++--
 5 files changed, 104 insertions(+), 12 deletions(-)

-- 
1.8.3.1
