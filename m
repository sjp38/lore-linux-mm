Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 4BC309000CE
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 20:49:45 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p8S0ngYO021478
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 17:49:42 -0700
Received: from iadk27 (iadk27.prod.google.com [10.12.137.27])
	by hpaq3.eem.corp.google.com with ESMTP id p8S0nTUJ024756
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 17:49:41 -0700
Received: by iadk27 with SMTP id k27so13243235iad.27
        for <linux-mm@kvack.org>; Tue, 27 Sep 2011 17:49:40 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 9/9] kstaled: export PG_stale in /proc/kpageflags
Date: Tue, 27 Sep 2011 17:49:07 -0700
Message-Id: <1317170947-17074-10-git-send-email-walken@google.com>
In-Reply-To: <1317170947-17074-1-git-send-email-walken@google.com>
References: <1317170947-17074-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>


Signed-off-by: Michel Lespinasse <walken@google.com>
---
 fs/proc/page.c                    |    4 ++++
 include/linux/kernel-page-flags.h |    2 ++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/fs/proc/page.c b/fs/proc/page.c
index 6d8e6a9..8c3f105 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -159,6 +159,10 @@ u64 stable_page_flags(struct page *page)
 	u |= kpf_copy_bit(k, KPF_OWNER_PRIVATE,	PG_owner_priv_1);
 	u |= kpf_copy_bit(k, KPF_ARCH,		PG_arch_1);
 
+#ifdef CONFIG_KSTALED
+	u |= kpf_copy_bit(k, KPF_STALE,         PG_stale);
+#endif
+
 	return u;
 };
 
diff --git a/include/linux/kernel-page-flags.h b/include/linux/kernel-page-flags.h
index bd92a89..f64acb3 100644
--- a/include/linux/kernel-page-flags.h
+++ b/include/linux/kernel-page-flags.h
@@ -31,6 +31,8 @@
 
 #define KPF_KSM			21
 
+#define KPF_STALE		22
+
 /* kernel hacking assistances
  * WARNING: subject to change, never rely on them!
  */
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
