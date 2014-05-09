Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id 554986B0035
	for <linux-mm@kvack.org>; Fri,  9 May 2014 16:43:35 -0400 (EDT)
Received: by mail-yh0-f48.google.com with SMTP id a41so2005761yho.35
        for <linux-mm@kvack.org>; Fri, 09 May 2014 13:43:35 -0700 (PDT)
Received: from mail-yk0-x22b.google.com (mail-yk0-x22b.google.com [2607:f8b0:4002:c07::22b])
        by mx.google.com with ESMTPS id e26si6958275yhd.104.2014.05.09.13.43.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 09 May 2014 13:43:34 -0700 (PDT)
Received: by mail-yk0-f171.google.com with SMTP id 142so3938777ykq.16
        for <linux-mm@kvack.org>; Fri, 09 May 2014 13:43:34 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH] plist: make CONFIG_DEBUG_PI_LIST selectable
Date: Fri,  9 May 2014 16:42:24 -0400
Message-Id: <1399668144-19738-1-git-send-email-ddstreet@ieee.org>
In-Reply-To: <20140505191341.GA18397@home.goodmis.org>
References: <20140505191341.GA18397@home.goodmis.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Weijie Yang <weijieut@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@fusionio.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>

Change CONFIG_DEBUG_PI_LIST to be user-selectable, and add a
title and description.  Remove the dependency on DEBUG_RT_MUTEXES
since they were changed to use rbtrees, and there are other users
of plists now.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Peter Zijlstra <peterz@infradead.org>
---
 lib/Kconfig.debug | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index e816930..a3b1d68 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -864,11 +864,6 @@ config DEBUG_RT_MUTEXES
 	 This allows rt mutex semantics violations and rt mutex related
 	 deadlocks (lockups) to be detected and reported automatically.
 
-config DEBUG_PI_LIST
-	bool
-	default y
-	depends on DEBUG_RT_MUTEXES
-
 config RT_MUTEX_TESTER
 	bool "Built-in scriptable tester for rt-mutexes"
 	depends on DEBUG_KERNEL && RT_MUTEXES
@@ -1094,6 +1089,16 @@ config DEBUG_LIST
 
 	  If unsure, say N.
 
+config DEBUG_PI_LIST
+	bool "Debug priority linked list manipulation"
+	depends on DEBUG_KERNEL
+	help
+	  Enable this to turn on extended checks in the priority-ordered
+	  linked-list (plist) walking routines.  This checks the entire
+	  list multiple times during each manipulation.
+
+	  If unsure, say N.
+
 config DEBUG_SG
 	bool "Debug SG table operations"
 	depends on DEBUG_KERNEL
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
