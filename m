Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D0A346B0003
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 19:59:51 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id d10-v6so5658374pgv.8
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 16:59:51 -0700 (PDT)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id v18-v6si16046824plo.285.2018.06.18.16.59.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 16:59:49 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [PATCH v2] doc: add description to dirtytime_expire_seconds
Date: Tue, 19 Jun 2018 07:59:18 +0800
Message-Id: <1529366358-67312-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tytso@mit.edu, nborisov@suse.com, corbet@lwn.net, akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

commit 1efff914afac8a965ad63817ecf8861a927c2ace ("fs: add
dirtytime_expire_seconds sysctl") introduced dirtytime_expire_seconds
knob, but there is not description about it in
Documentation/sysctl/vm.txt.

Add the description for it.

Cc: Theodore Ts'o <tytso@mit.edu>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
v1 --> v2: Rephrased the description per Nikolay Borisov's comment

I didn't dig into the old review discussion about why the description
was not added at the first place. I'm supposed every knob under /proc/sys
should have a brief description.

 Documentation/sysctl/vm.txt | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 17256f2..b078baf 100644
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
@@ -178,6 +179,18 @@ The total available memory is not equal to total system memory.
 
 ==============================================================
 
+dirtytime_expire_seconds
+
+When a lazytime inode is constantly having its pages dirtied, the inode with
+an updated timestamp will never get chance to be written out.  And, if the
+only thing that has happened on the file system is a dirtytime inode caused
+by an atime update, a worker will be scheduled to make sure that inode
+eventually gets pushed out to disk.  This tunable is used to define when dirty
+inode is old enough to be eligible for writeback by the kernel flusher threads.
+And, it is also used as the interval to wakeup dirtytime_writeback thread.
+
+==============================================================
+
 dirty_writeback_centisecs
 
 The kernel flusher threads will periodically wake up and write `old' data
-- 
1.8.3.1
