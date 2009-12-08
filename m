Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2BFC1600762
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:17:06 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
In-Reply-To: <200912081016.198135742@firstfloor.org>
Subject: [PATCH] [3/31] page-types: add standard GPL license header
Message-Id: <20091208211619.4B065B151F@basil.firstfloor.org>
Date: Tue,  8 Dec 2009 22:16:19 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.comfengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


From: Wu Fengguang <fengguang.wu@intel.com>

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 Documentation/vm/page-types.c |   15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

Index: linux/Documentation/vm/page-types.c
===================================================================
--- linux.orig/Documentation/vm/page-types.c
+++ linux/Documentation/vm/page-types.c
@@ -1,11 +1,22 @@
 /*
  * page-types: Tool for querying page flags
  *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; version 2.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should find a copy of v2 of the GNU General Public License somewhere on
+ * your Linux system; if not, write to the Free Software Foundation, Inc., 59
+ * Temple Place, Suite 330, Boston, MA 02111-1307 USA.
+ *
  * Copyright (C) 2009 Intel corporation
  *
  * Authors: Wu Fengguang <fengguang.wu@intel.com>
- *
- * Released under the General Public License (GPL).
  */
 
 #define _LARGEFILE64_SOURCE

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
