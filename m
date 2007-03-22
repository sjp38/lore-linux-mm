From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 22 Mar 2007 17:01:28 +1100
Subject: [RFC/PATCH 12/15] get_unmapped_area handles MAP_FIXED in ffb DRM
In-Reply-To: <1174543217.531981.572863804039.qpush@grosgo>
Message-Id: <20070322060302.72AE6DE40D@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

---

 drivers/char/drm/ffb_drv.c |    6 ++++++
 1 file changed, 6 insertions(+)

Index: linux-cell/drivers/char/drm/ffb_drv.c
===================================================================
--- linux-cell.orig/drivers/char/drm/ffb_drv.c	2007-03-22 16:21:22.000000000 +1100
+++ linux-cell/drivers/char/drm/ffb_drv.c	2007-03-22 16:23:13.000000000 +1100
@@ -191,6 +191,12 @@ unsigned long ffb_get_unmapped_area(stru
 			if ((kvirt & (SHMLBA - 1)) != (addr & (SHMLBA - 1))) {
 				unsigned long koff, aoff;
 
+				/* Address needs adjusting which can't be done
+				 * for MAP_FIXED
+				 */
+				if (flags & MAP_FIXED)
+					return -EINVAL;
+
 				koff = kvirt & (SHMLBA - 1);
 				aoff = addr & (SHMLBA - 1);
 				if (koff < aoff)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
