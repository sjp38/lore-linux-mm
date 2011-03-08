Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 16DFC8D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 16:49:37 -0500 (EST)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1578060Ab1CHVtT (ORCPT <rfc822;linux-mm@kvack.org>);
	Tue, 8 Mar 2011 22:49:19 +0100
Date: Tue, 8 Mar 2011 22:49:19 +0100
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH R4 5/7] xen/balloon: Minor notation fixes
Message-ID: <20110308214919.GF27331@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Minor notation fixes.

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 drivers/xen/balloon.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 6bae013..431e9f0 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -592,11 +592,11 @@ static struct attribute *balloon_info_attrs[] = {
 
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
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
