Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id AB2776B0083
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 17:59:47 -0500 (EST)
Received: by vcqp1 with SMTP id p1so149265vcq.2
        for <linux-mm@kvack.org>; Mon, 27 Feb 2012 14:59:46 -0800 (PST)
MIME-Version: 1.0
From: Suleiman Souhlal <ssouhlal@FreeBSD.org>
Subject: [PATCH 04/10] memcg: Introduce __GFP_NOACCOUNT.
Date: Mon, 27 Feb 2012 14:58:47 -0800
Message-Id: <1330383533-20711-5-git-send-email-ssouhlal@FreeBSD.org>
In-Reply-To: <1330383533-20711-1-git-send-email-ssouhlal@FreeBSD.org>
References: <1330383533-20711-1-git-send-email-ssouhlal@FreeBSD.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: suleiman@google.com, glommer@parallels.com, kamezawa.hiroyu@jp.fujitsu.com, penberg@kernel.org, yinghan@google.com, hughd@google.com, gthelen@google.com, linux-mm@kvack.org, devel@openvz.org, Suleiman Souhlal <ssouhlal@FreeBSD.org>

This is used to indicate that we don't want an allocation to be accounted
to the current cgroup.

Signed-off-by: Suleiman Souhlal <suleiman@google.com>
---
 include/linux/gfp.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 581e74b..765c20f 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -23,6 +23,7 @@ struct vm_area_struct;
 #define ___GFP_REPEAT		0x400u
 #define ___GFP_NOFAIL		0x800u
 #define ___GFP_NORETRY		0x1000u
+#define ___GFP_NOACCOUNT	0x2000u
 #define ___GFP_COMP		0x4000u
 #define ___GFP_ZERO		0x8000u
 #define ___GFP_NOMEMALLOC	0x10000u
@@ -76,6 +77,7 @@ struct vm_area_struct;
 #define __GFP_REPEAT	((__force gfp_t)___GFP_REPEAT)	/* See above */
 #define __GFP_NOFAIL	((__force gfp_t)___GFP_NOFAIL)	/* See above */
 #define __GFP_NORETRY	((__force gfp_t)___GFP_NORETRY) /* See above */
+#define __GFP_NOACCOUNT	((__force gfp_t)___GFP_NOACCOUNT) /* Don't account to the current cgroup */
 #define __GFP_COMP	((__force gfp_t)___GFP_COMP)	/* Add compound page metadata */
 #define __GFP_ZERO	((__force gfp_t)___GFP_ZERO)	/* Return zeroed page on success */
 #define __GFP_NOMEMALLOC ((__force gfp_t)___GFP_NOMEMALLOC) /* Don't use emergency reserves */
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
