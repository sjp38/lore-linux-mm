Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 555A56B0044
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 10:23:12 -0400 (EDT)
Received: by bkcjc3 with SMTP id jc3so397032bkc.14
        for <linux-mm@kvack.org>; Fri, 03 Aug 2012 07:23:10 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [RFC v2 0/7] generic hashtable implementation
Date: Fri,  3 Aug 2012 16:23:01 +0200
Message-Id: <1344003788-1417-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

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


Changes in V2:

 - Address review comments by Tejun Heo, Josh Triplett and Eric Beiderman (Thanks all!).
 - Rebase on top of latest master.
 - Convert more places to use the hashtable. Hopefully it will trigger more reviews by
 touching more subsystems.

Sasha Levin (7):
  hashtable: introduce a small and naive hashtable
  user_ns: use new hashtable implementation
  mm,ksm: use new hashtable implementation
  workqueue: use new hashtable implementation
  mm/huge_memory: use new hashtable implementation
  tracepoint: use new hashtable implementation
  net,9p: use new hashtable implementation

 include/linux/hashtable.h |   75 ++++++++++++++++++++++++++++++++++++
 kernel/tracepoint.c       |   26 ++++--------
 kernel/user.c             |   53 +++++++++-----------------
 kernel/workqueue.c        |   93 +++++++--------------------------------------
 mm/huge_memory.c          |   56 +++++----------------------
 mm/ksm.c                  |   29 ++++----------
 net/9p/error.c            |   17 ++++----
 7 files changed, 144 insertions(+), 205 deletions(-)
 create mode 100644 include/linux/hashtable.h

-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
