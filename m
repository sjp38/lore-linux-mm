Subject: [2/6] generify memory present
Message-Id: <E1DTQOW-0002V4-TN@pinky.shadowen.org>
From: Andy Whitcroft <apw@shadowen.org>
Date: Wed, 04 May 2005 21:22:56 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org, haveblue@us.ibm.com, kravetz@us.ibm.com
List-ID: <linux-mm.kvack.org>

Allow architectures to indicate that they will be providing hooks to
indice installed memory areas, memory_present().  Provide prototypes
for the i386 implementation.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
Signed-off-by: Martin Bligh <mbligh@aracnet.com>
---
 arch/i386/Kconfig |    2 +-
 mm/Kconfig        |    4 ++++
 2 files changed, 5 insertions(+), 1 deletion(-)

diff -X /home/apw/brief/lib/vdiff.excl -rupN reference/arch/i386/Kconfig current/arch/i386/Kconfig
--- reference/arch/i386/Kconfig	2005-05-04 20:54:26.000000000 +0100
+++ current/arch/i386/Kconfig	2005-05-04 20:54:26.000000000 +0100
@@ -777,7 +777,7 @@ config HAVE_ARCH_BOOTMEM_NODE
 	depends on NUMA
 	default y
 
-config HAVE_MEMORY_PRESENT
+config ARCH_HAVE_MEMORY_PRESENT
 	bool
 	depends on DISCONTIGMEM
 	default y
diff -X /home/apw/brief/lib/vdiff.excl -rupN reference/mm/Kconfig current/mm/Kconfig
--- reference/mm/Kconfig	2005-05-04 20:54:24.000000000 +0100
+++ current/mm/Kconfig	2005-05-04 20:54:26.000000000 +0100
@@ -53,3 +53,7 @@ config FLATMEM
 config NEED_MULTIPLE_NODES
 	def_bool y
 	depends on DISCONTIGMEM || NUMA
+
+config HAVE_MEMORY_PRESENT
+	def_bool y
+	depends on ARCH_HAVE_MEMORY_PRESENT
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
