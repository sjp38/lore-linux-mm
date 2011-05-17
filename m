Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4780B6B0022
	for <linux-mm@kvack.org>; Tue, 17 May 2011 05:41:16 -0400 (EDT)
Date: Tue, 17 May 2011 10:41:11 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: tracing: Add missing GFP flags to tracing
Message-ID: <20110517094111.GJ5279@suse.de>
References: <20110510100954.GC4146@suse.de>
 <20110510145446.1f8e77e3.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110510145446.1f8e77e3.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org

(For 2.6.38-stable)

include/linux/gfp.h and include/trace/events/gfpflags.h is out of
sync. When tracing is enabled, certain flags are not recognised and
the text output is less useful as a result.  Add the missing flags.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/trace/events/gfpflags.h |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/include/trace/events/gfpflags.h b/include/trace/events/gfpflags.h
index e3615c0..5cb8c1b 100644
--- a/include/trace/events/gfpflags.h
+++ b/include/trace/events/gfpflags.h
@@ -10,6 +10,7 @@
  */
 #define show_gfp_flags(flags)						\
 	(flags) ? __print_flags(flags, "|",				\
+	{(unsigned long)GFP_TRANSHUGE,		"GFP_TRANSHUGE"},	\
 	{(unsigned long)GFP_HIGHUSER_MOVABLE,	"GFP_HIGHUSER_MOVABLE"}, \
 	{(unsigned long)GFP_HIGHUSER,		"GFP_HIGHUSER"},	\
 	{(unsigned long)GFP_USER,		"GFP_USER"},		\
@@ -32,6 +33,8 @@
 	{(unsigned long)__GFP_HARDWALL,		"GFP_HARDWALL"},	\
 	{(unsigned long)__GFP_THISNODE,		"GFP_THISNODE"},	\
 	{(unsigned long)__GFP_RECLAIMABLE,	"GFP_RECLAIMABLE"},	\
-	{(unsigned long)__GFP_MOVABLE,		"GFP_MOVABLE"}		\
+	{(unsigned long)__GFP_MOVABLE,		"GFP_MOVABLE"},		\
+	{(unsigned long)__GFP_NOTRACK,		"GFP_NOTRACK"},		\
+	{(unsigned long)__GFP_NO_KSWAPD,	"GFP_NO_KSWAPD"}	\
 	) : "GFP_NOWAIT"
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
