Date: Fri, 02 May 2003 09:54:43 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: 2.5.68-mm4
Message-ID: <31670000.1051894482@[10.10.2.4]>
In-Reply-To: <20030502020149.1ec3e54f.akpm@digeo.com>
References: <20030502020149.1ec3e54f.akpm@digeo.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==========878600887=========="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andi Kleen <ak@muc.de>
List-ID: <linux-mm.kvack.org>

--==========878600887==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Fix up NUMA-Q build with new generic apic mode stuff


--==========878600887==========
Content-Type: text/plain; charset=iso-8859-1; name=mm4-fixed
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename=mm4-fixed; size=777

diff -urpN -X /home/fletch/.diff.exclude =
mm4/include/asm-i386/mach-numaq/mach_apic.h =
mm4-fixed/include/asm-i386/mach-numaq/mach_apic.h
--- mm4/include/asm-i386/mach-numaq/mach_apic.h	Wed Mar  5 07:37:06 2003
+++ mm4-fixed/include/asm-i386/mach-numaq/mach_apic.h	Fri May  2 09:45:58 =
2003
@@ -1,6 +1,9 @@
 #ifndef __ASM_MACH_APIC_H
 #define __ASM_MACH_APIC_H
=20
+#include <asm/io.h>
+#include <linux/mmzone.h>
+
 #define APIC_DFR_VALUE	(APIC_DFR_CLUSTER)
=20
 #define TARGET_CPUS (0xf)
@@ -102,5 +105,14 @@ static inline int check_phys_apicid_pres
 {
 	return (1);
 }
+
+#define APIC_ID_MASK (0xF<<24)
+
+static inline unsigned get_apic_id(unsigned long x)
+{
+	        return (((x)>>24)&0x0F);
+}
+
+#define         GET_APIC_ID(x)  get_apic_id(x)
=20
 #endif /* __ASM_MACH_APIC_H */

--==========878600887==========--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
