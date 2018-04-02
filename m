Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7D14F6B0011
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 01:31:32 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 184so13185934iow.19
        for <linux-mm@kvack.org>; Sun, 01 Apr 2018 22:31:32 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id j5-v6si2527370ita.112.2018.04.01.22.31.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Apr 2018 22:31:31 -0700 (PDT)
From: rao.shoaib@oracle.com
Subject: [PATCH 0/2] Move kfree_rcu out of rcu code and use kfree_bulk
Date: Sun,  1 Apr 2018 22:31:02 -0700
Message-Id: <1522647064-27167-1-git-send-email-rao.shoaib@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: paulmck@linux.vnet.ibm.com, joe@perches.com, willy@infradead.org, brouer@redhat.com, linux-mm@kvack.org, Rao Shoaib <rao.shoaib@oracle.com>

From: Rao Shoaib <rao.shoaib@oracle.com>

This patch moves kfree_call_rcu() out of rcu related code to
mm/slab_common and updates kfree_rcu() to use new bulk memory free
functions as they are more efficient.

This is a resubmission of the previous patch.

Changes:

1) checkpatch.pl has been fixed, so kfree_rcu macro is much simpler

2) To handle preemption, preempt_enable()/preempt_disable() statements
   have been added to __rcu_bulk_free().


Rao Shoaib (2):
  Move kfree_call_rcu() to slab_common.c
  kfree_rcu() should use kfree_bulk() interface

 include/linux/mm.h       |   5 ++
 include/linux/rcupdate.h |  43 +-----------
 include/linux/rcutiny.h  |   8 ++-
 include/linux/rcutree.h  |   2 -
 include/linux/slab.h     |  42 ++++++++++++
 kernel/rcu/tree.c        |  24 +++----
 kernel/sysctl.c          |  40 +++++++++++
 mm/slab.h                |  23 +++++++
 mm/slab_common.c         | 172 +++++++++++++++++++++++++++++++++++++++++++++++
 9 files changed, 302 insertions(+), 57 deletions(-)

-- 
2.7.4
