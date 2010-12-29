Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 025976B009A
	for <linux-mm@kvack.org>; Wed, 29 Dec 2010 12:07:33 -0500 (EST)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1564513Ab0L2RGY (ORCPT <rfc822;linux-mm@kvack.org>);
	Wed, 29 Dec 2010 18:06:24 +0100
Date: Wed, 29 Dec 2010 18:06:24 +0100
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH R2 6/7] xen/balloon: Minor notation fixes
Message-ID: <20101229170624.GK2743@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Minor notation fixes.

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 drivers/xen/balloon.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index a62427d..f105e67 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -575,11 +575,11 @@ static struct attribute *balloon_info_attrs[] = {
 
 static struct attribute_group balloon_info_group = {
 	.name = "info",
-	.attrs = balloon_info_attrs,
+	.attrs = balloon_info_attrs
 };
 
 static struct sysdev_class balloon_sysdev_class = {
-	.name = BALLOON_CLASS_NAME,
+	.name = BALLOON_CLASS_NAME
 };
 
 static int register_balloon(struct sys_device *sysdev)
-- 
1.4.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
