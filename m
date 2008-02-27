Message-ID: <47C51331.8060700@openvz.org>
Date: Wed, 27 Feb 2008 10:37:21 +0300
From: Pavel Emelyanov <xemul@openvz.org>
MIME-Version: 1.0
Subject: Add Pavel as the co-maintainer for memory resource controller
References: <20080227040246.GA27018@balbir.in.ibm.com>
In-Reply-To: <20080227040246.GA27018@balbir.in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

I'm also interested in supporting this feature, all the more
so, we're planning to move OpenVZ development branch to 2.6.25
soon to make use of namespaces and controller(s) that are
already there.

Please, add me as the co-maintainer of a memory controller.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/MAINTAINERS b/MAINTAINERS
index 4623c24..85bfcd4 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2642,6 +2642,8 @@ S:	Maintained
 MEMORY RESOURCE CONTROLLER
 P:	Balbir Singh
 M:	balbir@linux.vnet.ibm.com
+P:	Pavel Emelyanov
+M:	xemul@openvz.org
 L:	linux-mm@kvack.org
 L:	linux-kernel@vger.kernel.org
 S:	Maintained

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
