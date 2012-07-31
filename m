Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 8D06C6B00A6
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 14:04:59 -0400 (EDT)
Received: by bkcjc3 with SMTP id jc3so4023084bkc.14
        for <linux-mm@kvack.org>; Tue, 31 Jul 2012 11:04:57 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [RFC 0/4] generic hashtable implementation
Date: Tue, 31 Jul 2012 20:05:16 +0200
Message-Id: <1343757920-19713-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, Sasha Levin <levinsasha928@gmail.com>

There are quite a few places in the kernel which implement a hashtable
in a very similar way. Instead of having implementations of a hashtable
all over the kernel, we can re-use the code.

This patch series introduces a very simple hashtable implementation, and
modifies three (random) modules to use it. I've limited it to 3 only
so that it would be easy to review and modify, and to show that even
at this number we already eliminate a big amount of duplicated code.

If this basic hashtable looks ok, future code will include:

 - RCU support
 - Self locking (list_bl?)
 - Converting more code to use the hashtable


Sasha Levin (4):
  hashtable: introduce a small and naive hashtable
  user_ns: use new hashtable implementation
  mm,ksm: use new hashtable implementation
  workqueue: use new hashtable implementation

 include/linux/hashtable.h      |   46 ++++++++++++++++++++
 include/linux/user_namespace.h |   11 +++--
 kernel/user.c                  |   54 ++++-------------------
 kernel/user_namespace.c        |    4 +-
 kernel/workqueue.c             |   91 ++++++---------------------------------
 mm/ksm.c                       |   29 ++++---------
 6 files changed, 87 insertions(+), 148 deletions(-)
 create mode 100644 include/linux/hashtable.h

-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
