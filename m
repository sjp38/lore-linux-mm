From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 01/24] page-types: add standard GPL license head
Date: Wed, 02 Dec 2009 11:12:32 +0800
Message-ID: <20091202043043.715851393@intel.com>
References: <20091202031231.735876003@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4DA726B007D
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 23:37:37 -0500 (EST)
Content-Disposition: inline; filename=page-types-gpl.patch
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

CC: Andi Kleen <andi@firstfloor.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 Documentation/vm/page-types.c |   15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

--- linux-mm.orig/Documentation/vm/page-types.c	2009-11-07 19:28:51.000000000 +0800
+++ linux-mm/Documentation/vm/page-types.c	2009-11-08 22:04:04.000000000 +0800
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
