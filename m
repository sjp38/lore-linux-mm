From: Christoph Lameter <cl@linux-foundation.org>
Subject: [patch 3/3] Increase default reserve percpu area
Date: Fri, 19 Sep 2008 13:37:06 -0700
Message-ID: <20080919203724.474751340@quilx.com>
References: <20080919203703.312007962@quilx.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756095AbYISUkl@vger.kernel.org>
Content-Disposition: inline; filename=cpu_alloc_increase_percpu_default
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org, penberg@cs.helsinki.fi
List-Id: linux-mm.kvack.org

SLUB now requires a portion of the per cpu reserve. There are on average
about 70 real slabs on a system (aliases do not count) and each needs 12 bytes
of per cpu space. Thats 840 bytes. In debug mode all slabs will be real slabs
which will make us end up with 150 -> 1800. Give it some slack and add 2000
bytes to the default size.

Things work fine without this patch but then slub will reduce the percpu reserve
for modules.

Also define a reserve if CONFIG_MODULES is off.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

Index: linux-2.6/include/linux/percpu.h
===================================================================
--- linux-2.6.orig/include/linux/percpu.h	2008-09-19 15:04:21.000000000 -0500
+++ linux-2.6/include/linux/percpu.h	2008-09-19 15:05:31.000000000 -0500
@@ -38,9 +38,9 @@
 /* Enough to cover all DEFINE_PER_CPUs in kernel, including modules. */
 #ifndef PERCPU_AREA_SIZE
 #ifdef CONFIG_MODULES
-#define PERCPU_RESERVE_SIZE	8192
+#define PERCPU_RESERVE_SIZE	10000
 #else
-#define PERCPU_RESERVE_SIZE	0
+#define PERCPU_RESERVE_SIZE	2000
 #endif
 
 #define PERCPU_AREA_SIZE						\

-- 
