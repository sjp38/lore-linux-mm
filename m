Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8720C6B01B0
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 14:51:06 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 19 Mar 2010 14:59:52 -0400
Message-Id: <20100319185952.21430.8872.sendpatchset@localhost.localdomain>
In-Reply-To: <20100319185933.21430.72039.sendpatchset@localhost.localdomain>
References: <20100319185933.21430.72039.sendpatchset@localhost.localdomain>
Subject: [PATCH 3/6] Mempolicy: rename policy_types and cleanup initialization
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Ravikiran Thirumalai <kiran@scalex86.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

Rename 'policy_types[]' to 'policy_modes[]' to better match the
array contents.

Use designated intializer syntax for policy_modes[].

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/mempolicy.c |   18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

Index: linux-2.6.34-rc1-mmotm-100311-1313/mm/mempolicy.c
===================================================================
--- linux-2.6.34-rc1-mmotm-100311-1313.orig/mm/mempolicy.c	2010-03-19 09:03:21.000000000 -0400
+++ linux-2.6.34-rc1-mmotm-100311-1313/mm/mempolicy.c	2010-03-19 12:22:17.000000000 -0400
@@ -2127,9 +2127,15 @@ void numa_default_policy(void)
  * "local" is pseudo-policy:  MPOL_PREFERRED with MPOL_F_LOCAL flag
  * Used only for mpol_parse_str() and mpol_to_str()
  */
-#define MPOL_LOCAL (MPOL_INTERLEAVE + 1)
-static const char * const policy_types[] =
-	{ "default", "prefer", "bind", "interleave", "local" };
+#define MPOL_LOCAL MPOL_MAX
+static const char * const policy_modes[] =
+{
+ 	[MPOL_DEFAULT]    = "default",
+ 	[MPOL_PREFERRED]  = "prefer",
+	[MPOL_BIND]       = "bind",
+	[MPOL_INTERLEAVE] = "interleave",
+	[MPOL_LOCAL]      = "local"
+};
 
 
 #ifdef CONFIG_TMPFS
@@ -2175,7 +2181,7 @@ int mpol_parse_str(char *str, struct mem
 		*flags++ = '\0';	/* terminate mode string */
 
 	for (mode = 0; mode <= MPOL_LOCAL; mode++) {
-		if (!strcmp(str, policy_types[mode])) {
+		if (!strcmp(str, policy_modes[mode])) {
 			break;
 		}
 	}
@@ -2330,11 +2336,11 @@ int mpol_to_str(char *buffer, int maxlen
 		BUG();
 	}
 
-	l = strlen(policy_types[mode]);
+	l = strlen(policy_modes[mode]);
 	if (buffer + maxlen < p + l + 1)
 		return -ENOSPC;
 
-	strcpy(p, policy_types[mode]);
+	strcpy(p, policy_modes[mode]);
 	p += l;
 
 	if (flags & MPOL_MODE_FLAGS) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
