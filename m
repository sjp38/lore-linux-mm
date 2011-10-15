Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 866886B0184
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 20:39:03 -0400 (EDT)
From: Suleiman Souhlal <ssouhlal@FreeBSD.org>
Subject: [RFC] [PATCH 2/4] memcg: Introduce __GFP_NOACCOUNT.
Date: Fri, 14 Oct 2011 17:38:28 -0700
Message-Id: <1318639110-27714-3-git-send-email-ssouhlal@FreeBSD.org>
In-Reply-To: <1318639110-27714-2-git-send-email-ssouhlal@FreeBSD.org>
References: <1318639110-27714-1-git-send-email-ssouhlal@FreeBSD.org>
 <1318639110-27714-2-git-send-email-ssouhlal@FreeBSD.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: glommer@parallels.com
Cc: gthelen@google.com, yinghan@google.com, kamezawa.hiroyu@jp.fujitsu.com, jbottomley@parallels.com, suleiman@google.com, linux-mm@kvack.org, Suleiman Souhlal <ssouhlal@FreeBSD.org>

This is used to indicate that we don't want an allocation to be accounted
to the current cgroup.

Signed-off-by: Suleiman Souhlal <suleiman@google.com>
---
 include/linux/gfp.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 3a76faf..480075b 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -23,6 +23,7 @@ struct vm_area_struct;
 #define ___GFP_REPEAT		0x400u
 #define ___GFP_NOFAIL		0x800u
 #define ___GFP_NORETRY		0x1000u
+#define	___GFP_NOACCOUNT	0x2000u
 #define ___GFP_COMP		0x4000u
 #define ___GFP_ZERO		0x8000u
 #define ___GFP_NOMEMALLOC	0x10000u
@@ -75,6 +76,7 @@ struct vm_area_struct;
 #define __GFP_REPEAT	((__force gfp_t)___GFP_REPEAT)	/* See above */
 #define __GFP_NOFAIL	((__force gfp_t)___GFP_NOFAIL)	/* See above */
 #define __GFP_NORETRY	((__force gfp_t)___GFP_NORETRY) /* See above */
+#define	__GFP_NOACCOUNT	((__force gfp_t)___GFP_NOACCOUNT) /* Don't account to the current cgroup */
 #define __GFP_COMP	((__force gfp_t)___GFP_COMP)	/* Add compound page metadata */
 #define __GFP_ZERO	((__force gfp_t)___GFP_ZERO)	/* Return zeroed page on success */
 #define __GFP_NOMEMALLOC ((__force gfp_t)___GFP_NOMEMALLOC) /* Don't use emergency reserves */
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
