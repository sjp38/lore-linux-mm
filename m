Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7A7E628027B
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 09:28:07 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id y6so15520415lff.0
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 06:28:07 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id 184si1083939lfz.63.2016.09.27.06.28.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 06:28:05 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id l131so1795878lfl.0
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 06:28:05 -0700 (PDT)
From: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Subject: [PATCH 1/1] man/set_mempolicy.2,mbind.2: forbid static or relative flags for local NUMA mode
Date: Tue, 27 Sep 2016 15:27:50 +0200
Message-Id: <20160927132750.12188-1-kwapulinski.piotr@gmail.com>
In-Reply-To: <alpine.DEB.2.10.1609201304450.134671@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1609201304450.134671@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mtk.manpages@gmail.com
Cc: kirill.shutemov@linux.intel.com, vbabka@suse.cz, rientjes@google.com, mhocko@kernel.org, mgorman@techsingularity.net, liangchen.linux@gmail.com, nzimmer@sgi.com, a.p.zijlstra@chello.nl, cl@linux.com, riel@redhat.com, lee.schermerhorn@hp.com, jmarchan@redhat.com, joe@perches.com, corbet@lwn.net, iamyooon@gmail.com, n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-man@vger.kernel.org, akpm@linux-foundation.org, linux-doc@vger.kernel.org, linux-api@vger.kernel.org, kwapulinski.piotr@gmail.com

Add documentation for the following patch:
[PATCH v2 0/1] mm/mempolicy.c: forbid static or relative flags
 for local NUMA mode

Signed-off-by: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
---
 man2/mbind.2         | 35 +++++++++++++++++++++++++++++++++++
 man2/set_mempolicy.2 | 35 +++++++++++++++++++++++++++++++++++
 2 files changed, 70 insertions(+)

diff --git a/man2/mbind.2 b/man2/mbind.2
index 3ea24f6..8c50948 100644
--- a/man2/mbind.2
+++ b/man2/mbind.2
@@ -375,6 +375,41 @@ argument specified both
 .B MPOL_F_STATIC_NODES
 and
 .BR MPOL_F_RELATIVE_NODES .
+Or, the
+.I mode
+argument specifies
+.B MPOL_PREFERRED
+and
+.B MPOL_F_STATIC_NODES
+flag and
+.I nodemask
+is empty. Or, the
+.I mode
+argument specifies
+.B MPOL_PREFERRED
+and
+.B MPOL_F_RELATIVE_NODES
+flag and
+.I nodemask
+is empty. Or, the
+.I mode
+is
+.B MPOL_LOCAL
+and
+.I nodemask
+is empty. Or, the
+.I mode
+argument specifies
+.B MPOL_LOCAL
+and
+.B MPOL_F_STATIC_NODES
+flag. Or, the
+.I mode
+argument specifies
+.B MPOL_LOCAL
+and
+.B MPOL_F_RELATIVE_NODES
+flag.
 .TP
 .B EIO
 .B MPOL_MF_STRICT
diff --git a/man2/set_mempolicy.2 b/man2/set_mempolicy.2
index 1f02037..9204941 100644
--- a/man2/set_mempolicy.2
+++ b/man2/set_mempolicy.2
@@ -269,6 +269,41 @@ argument specified both
 .B MPOL_F_STATIC_NODES
 and
 .BR MPOL_F_RELATIVE_NODES .
+Or, the
+.I mode
+argument specifies
+.B MPOL_PREFERRED
+and
+.B MPOL_F_STATIC_NODES
+flag and
+.I nodemask
+is empty. Or, the
+.I mode
+argument specifies
+.B MPOL_PREFERRED
+and
+.B MPOL_F_RELATIVE_NODES
+flag and
+.I nodemask
+is empty. Or, the
+.I mode
+is
+.B MPOL_LOCAL
+and
+.I nodemask
+is empty. Or, the
+.I mode
+argument specifies
+.B MPOL_LOCAL
+and
+.B MPOL_F_STATIC_NODES
+flag. Or, the
+.I mode
+argument specifies
+.B MPOL_LOCAL
+and
+.B MPOL_F_RELATIVE_NODES
+flag.
 .TP
 .B ENOMEM
 Insufficient kernel memory was available.
-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
