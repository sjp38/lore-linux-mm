Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5878028027B
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 09:21:25 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id b71so17279894lfg.2
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 06:21:25 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id e84si1061295lji.62.2016.09.27.06.21.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 06:21:23 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id s64so1788483lfs.2
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 06:21:23 -0700 (PDT)
From: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Subject: [PATCH 0/1] man/set_mempolicy.2,mbind.2: add MPOL_LOCAL NUMA memory policy documentation
Date: Tue, 27 Sep 2016 15:19:48 +0200
Message-Id: <20160927131948.11974-1-kwapulinski.piotr@gmail.com>
In-Reply-To: <alpine.DEB.2.10.1609201304450.134671@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1609201304450.134671@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mtk.manpages@gmail.com
Cc: kirill.shutemov@linux.intel.com, vbabka@suse.cz, rientjes@google.com, mhocko@kernel.org, mgorman@techsingularity.net, liangchen.linux@gmail.com, nzimmer@sgi.com, a.p.zijlstra@chello.nl, cl@linux.com, riel@redhat.com, lee.schermerhorn@hp.com, jmarchan@redhat.com, joe@perches.com, corbet@lwn.net, iamyooon@gmail.com, n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-man@vger.kernel.org, akpm@linux-foundation.org, linux-doc@vger.kernel.org, linux-api@vger.kernel.org, kwapulinski.piotr@gmail.com

The MPOL_LOCAL mode has been implemented by
Peter Zijlstra <a.p.zijlstra@chello.nl>
(commit: 479e2802d09f1e18a97262c4c6f8f17ae5884bd8).
Add the documentation for this mode.

Signed-off-by: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
---
 man2/mbind.2         | 16 ++++++++++++----
 man2/set_mempolicy.2 | 11 ++++++++++-
 2 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/man2/mbind.2 b/man2/mbind.2
index 3ea24f6..b184f4e 100644
--- a/man2/mbind.2
+++ b/man2/mbind.2
@@ -130,8 +130,9 @@ argument must specify one of
 .BR MPOL_DEFAULT ,
 .BR MPOL_BIND ,
 .BR MPOL_INTERLEAVE ,
+.BR MPOL_PREFERRED ,
 or
-.BR MPOL_PREFERRED .
+.BR MPOL_LOCAL .
 All policy modes except
 .B MPOL_DEFAULT
 require the caller to specify via the
@@ -258,9 +259,14 @@ and
 .I maxnode
 arguments specify the empty set, then the memory is allocated on
 the node of the CPU that triggered the allocation.
-This is the only way to specify "local allocation" for a
-range of memory via
-.BR mbind ().
+
+.B MPOL_LOCAL
+specifies the "local allocation", the memory is allocated on
+the node of the CPU that triggered the allocation. The
+.I nodemask
+and
+.I maxnode
+arguments must specify the empty set.
 
 If
 .B MPOL_MF_STRICT
@@ -440,6 +446,8 @@ To select explicit "local allocation" for a memory range,
 specify a
 .I mode
 of
+.B MPOL_LOCAL
+or
 .B MPOL_PREFERRED
 with an empty set of nodes.
 This method will work for
diff --git a/man2/set_mempolicy.2 b/man2/set_mempolicy.2
index 1f02037..5755322 100644
--- a/man2/set_mempolicy.2
+++ b/man2/set_mempolicy.2
@@ -79,8 +79,9 @@ argument must specify one of
 .BR MPOL_DEFAULT ,
 .BR MPOL_BIND ,
 .BR MPOL_INTERLEAVE ,
+.BR MPOL_PREFERRED ,
 or
-.BR MPOL_PREFERRED .
+.BR MPOL_LOCAL .
 All modes except
 .B MPOL_DEFAULT
 require the caller to specify via the
@@ -211,6 +212,14 @@ arguments specify the empty set, then the policy
 specifies "local allocation"
 (like the system default policy discussed above).
 
+.B MPOL_LOCAL
+specifies the "local allocation" (like the system default policy
+discussed above). The
+.I nodemask
+and
+.I maxnode
+arguments must specify the empty set.
+
 The thread memory policy is preserved across an
 .BR execve (2),
 and is inherited by child threads created using
-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
