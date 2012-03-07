Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 2A98B6B004D
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 07:11:42 -0500 (EST)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Wed, 7 Mar 2012 17:41:38 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q27CBXeU4272364
	for <linux-mm@kvack.org>; Wed, 7 Mar 2012 17:41:33 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q27Hg9db016979
	for <linux-mm@kvack.org>; Thu, 8 Mar 2012 04:42:10 +1100
Message-ID: <4F575073.60909@linux.vnet.ibm.com>
Date: Wed, 07 Mar 2012 20:11:31 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 2/2] rmap: remove __anon_vma_link
References: <4F575045.9010904@linux.vnet.ibm.com>
In-Reply-To: <4F575045.9010904@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

This declaration is not used anymore, remove it

Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 include/linux/rmap.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 1cdd62a..fd07c45 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -122,7 +122,6 @@ void unlink_anon_vmas(struct vm_area_struct *);
 int anon_vma_clone(struct vm_area_struct *, struct vm_area_struct *);
 void anon_vma_moveto_tail(struct vm_area_struct *);
 int anon_vma_fork(struct vm_area_struct *, struct vm_area_struct *);
-void __anon_vma_link(struct vm_area_struct *);

 static inline void anon_vma_merge(struct vm_area_struct *vma,
 				  struct vm_area_struct *next)
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
