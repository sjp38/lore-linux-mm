Message-Id: <20070531003012.302019683@sgi.com>
References: <20070531002047.702473071@sgi.com>
Date: Wed, 30 May 2007 17:20:48 -0700
From: clameter@sgi.com
Subject: [RFC 1/4] CONFIG_STABLE: Define it
Content-Disposition: inline; filename=stable_init
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Introduce CONFIG_STABLE to control checks only useful for development.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 init/Kconfig |    7 +++++++
 1 file changed, 7 insertions(+)

Index: slub/init/Kconfig
===================================================================
--- slub.orig/init/Kconfig	2007-05-30 16:35:05.000000000 -0700
+++ slub/init/Kconfig	2007-05-30 16:35:45.000000000 -0700
@@ -65,6 +65,13 @@ endmenu
 
 menu "General setup"
 
+config STABLE
+	bool "Stable kernel"
+	help
+	  If the kernel is configured to be a stable kernel then various
+	  checks that are only of interest to kernel development will be
+	  omitted.
+
 config LOCALVERSION
 	string "Local version - append to kernel release"
 	help

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
