Message-ID: <3FE000FD.2090408@sgi.com>
Date: Wed, 17 Dec 2003 01:08:45 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: lockmeter on ia64
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Hanna Linder <hannal@us.ibm.com>, "Martin J. Bligh" <mbligh@aracnet.com>, lse-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew,

It looks like the 2.6.0 lockmeter patch has lost the configuration menu entry to
enable lockmeter on ia64.  This is true of both 2.6.0-test10-mm1 and
2.6.0-test11-mjb3.  (Martin appears to pull this from your tree.)  Below is
the trivial patch to fix this.  With this change it appears to work fine on
Altix, at least.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#                  ChangeSet    1.1520  -> 1.1521
#          arch/ia64/Kconfig    1.49    -> 1.50
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/12/16      raybry@tomahawk.engr.sgi.com    1.1521
# Add missing menu item for Lockmeter in arch/ia64/Kconfig
# --------------------------------------------
#
diff -Nru a/arch/ia64/Kconfig b/arch/ia64/Kconfig
--- a/arch/ia64/Kconfig Tue Dec 16 16:44:00 2003
+++ b/arch/ia64/Kconfig Tue Dec 16 16:44:00 2003
@@ -686,6 +686,13 @@
           debugging info resulting in a larger kernel image.
           Say Y here only if you plan to use gdb to debug the kernel.
           If you don't debug the kernel, you can say N.
+
+config LOCKMETER
+       bool "Kernel lock metering"
+       depends on SMP
+       help
+         Say Y to enable kernel lock metering, which adds overhead to SMP locks,
+         but allows you to see various statistics using the lockstat command.

  endmenu



-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
