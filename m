From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 24 Apr 2007 15:33:34 +1000
Subject: [PATCH 2/12] get_unmapped_area handles MAP_FIXED on alpha
In-Reply-To: <1177392813.924664.32930750763.qpush@grosgo>
Message-Id: <20070424053337.49089DDF07@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Handle MAP_FIXED in alpha's arch_get_unmapped_area(), simple case, just
return the address as passed in

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

 arch/alpha/kernel/osf_sys.c |    3 +++
 1 file changed, 3 insertions(+)

Index: linux-cell/arch/alpha/kernel/osf_sys.c
===================================================================
--- linux-cell.orig/arch/alpha/kernel/osf_sys.c	2007-03-22 14:58:33.000000000 +1100
+++ linux-cell/arch/alpha/kernel/osf_sys.c	2007-03-22 14:58:44.000000000 +1100
@@ -1267,6 +1267,9 @@ arch_get_unmapped_area(struct file *filp
 	if (len > limit)
 		return -ENOMEM;
 
+	if (flags & MAP_FIXED)
+		return addr;
+
 	/* First, see if the given suggestion fits.
 
 	   The OSF/1 loader (/sbin/loader) relies on us returning an

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
