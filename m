Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 38E0B28027B
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 09:23:13 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id s64so16913427lfs.1
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 06:23:13 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id f137si1068544lfe.186.2016.09.27.06.23.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 06:23:11 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id s64so1790603lfs.2
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 06:23:11 -0700 (PDT)
From: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Subject: [PATCH 1/1] mm/mempolicy.c: add MPOL_LOCAL NUMA memory policy documentation
Date: Tue, 27 Sep 2016 15:22:54 +0200
Message-Id: <20160927132254.12050-1-kwapulinski.piotr@gmail.com>
In-Reply-To: <alpine.DEB.2.10.1609201304450.134671@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1609201304450.134671@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: kirill.shutemov@linux.intel.com, vbabka@suse.cz, rientjes@google.com, mhocko@kernel.org, mgorman@techsingularity.net, liangchen.linux@gmail.com, nzimmer@sgi.com, a.p.zijlstra@chello.nl, cl@linux.com, riel@redhat.com, lee.schermerhorn@hp.com, jmarchan@redhat.com, joe@perches.com, corbet@lwn.net, iamyooon@gmail.com, n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-man@vger.kernel.org, mtk.manpages@gmail.com, linux-doc@vger.kernel.org, linux-api@vger.kernel.org, kwapulinski.piotr@gmail.com

The MPOL_LOCAL mode has been implemented by
Peter Zijlstra <a.p.zijlstra@chello.nl>
(commit: 479e2802d09f1e18a97262c4c6f8f17ae5884bd8).
Add the documentation for this mode.

Signed-off-by: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
---
 Documentation/vm/numa_memory_policy.txt | 8 ++++++++
 mm/mempolicy.c                          | 4 ++++
 2 files changed, 12 insertions(+)

diff --git a/Documentation/vm/numa_memory_policy.txt b/Documentation/vm/numa_memory_policy.txt
index 622b927..dcb490e 100644
--- a/Documentation/vm/numa_memory_policy.txt
+++ b/Documentation/vm/numa_memory_policy.txt
@@ -212,6 +212,14 @@ Components of Memory Policies
 	    the temporary interleaved system default policy works in this
 	    mode.
 
+	MPOL_LOCAL: This mode specifies "local allocation". It must be
+	used along with an empty nodemask. It acts like the MPOL_PREFERRED
+	mode specified with an empty nodemask. For details refer to
+	the MPOL_PREFERRED mode described above.
+
+	    Internally, it is transformed into MPOL_PREFERRED mode with an
+	    empty nodemask.
+
    Linux memory policy supports the following optional mode flags:
 
 	MPOL_F_STATIC_NODES:  This flag specifies that the nodemask passed by
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 2da72a5..02dc43e 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -35,6 +35,10 @@
  *                use the process policy. This is what Linux always did
  *		  in a NUMA aware kernel and still does by, ahem, default.
  *
+ * local          "Local allocation". It acts like a special case of
+ *                "preferred" memory policy: NUMA_NO_NODE (see above
+ *                for details).
+ *
  * The process policy is applied for most non interrupt memory allocations
  * in that process' context. Interrupts ignore the policies and always
  * try to allocate on the local CPU. The VMA policy is only applied for memory
-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
