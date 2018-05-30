Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 544616B0003
	for <linux-mm@kvack.org>; Wed, 30 May 2018 19:57:27 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c4-v6so11669419pfg.22
        for <linux-mm@kvack.org>; Wed, 30 May 2018 16:57:27 -0700 (PDT)
Received: from out4438.biz.mail.alibaba.com (out4438.biz.mail.alibaba.com. [47.88.44.38])
        by mx.google.com with ESMTPS id i10-v6si28481305pgv.109.2018.05.30.16.57.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 May 2018 16:57:25 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [PATCH] doc: add description to dirtytime_expire_seconds
Date: Thu, 31 May 2018 07:56:53 +0800
Message-Id: <1527724613-17768-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tytso@mit.edu, corbet@lwn.net, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

commit 1efff914afac8a965ad63817ecf8861a927c2ace ("fs: add
dirtytime_expire_seconds sysctl") introduced dirtytime_expire_seconds
knob, but there is not description about it in
Documentation/sysctl/vm.txt.

Add the description for it.

Cc: Theodore Ts'o <tytso@mit.edu>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
I didn't dig into the old review discussion about why the description
was not added at the first place. I'm supposed every knob under /proc/sys
should have a brief description.

 Documentation/sysctl/vm.txt | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 17256f2..f4f4f9c 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -27,6 +27,7 @@ Currently, these files are in /proc/sys/vm:
 - dirty_bytes
 - dirty_expire_centisecs
 - dirty_ratio
+- dirtytime_expire_seconds
 - dirty_writeback_centisecs
 - drop_caches
 - extfrag_threshold
@@ -178,6 +179,16 @@ The total available memory is not equal to total system memory.
 
 ==============================================================
 
+dirtytime_expire_seconds
+
+When a lazytime inode is constantly having its pages dirtied, it with an
+updated timestamp will never get chance to be written out.  This tunable
+is used to define when dirty inode is old enough to be eligible for
+writeback by the kernel flusher threads. And, it is also used as the
+interval to wakeup dirtytime_writeback thread. It is expressed in seconds.
+
+==============================================================
+
 dirty_writeback_centisecs
 
 The kernel flusher threads will periodically wake up and write `old' data
-- 
1.8.3.1
