Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5B8946B006C
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 10:17:09 -0400 (EDT)
Received: by wizk4 with SMTP id k4so156753451wiz.1
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 07:17:08 -0700 (PDT)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id dl8si12725897wib.11.2015.04.15.07.17.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Apr 2015 07:17:06 -0700 (PDT)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 15 Apr 2015 15:17:05 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 0FBFE1B08069
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 15:17:37 +0100 (BST)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3FEH2sp3604784
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 14:17:02 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3FEH2GG018047
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 08:17:02 -0600
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v5 1/3] mm: New mm hook framework
Date: Wed, 15 Apr 2015 16:16:56 +0200
Message-Id: <1e5f6a7cc2c5b1b3d09afad37e5dc0c2910cf811.1429104776.git.ldufour@linux.vnet.ibm.com>
In-Reply-To: <cover.1429104776.git.ldufour@linux.vnet.ibm.com>
References: <cover.1429104776.git.ldufour@linux.vnet.ibm.com>
In-Reply-To: <cover.1429104776.git.ldufour@linux.vnet.ibm.com>
References: <20150414123853.a3e61b7fa95b6c634e0fcce0@linux-foundation.org> <cover.1429104776.git.ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Pavel Emelyanov <xemul@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Ingo Molnar <mingo@kernel.org>, linuxppc-dev@lists.ozlabs.org
Cc: cov@codeaurora.org, criu@openvz.org

This patch introduces a new set of header file to manage mm hooks:
- per architecture empty header file (arch/x/include/asm/mm-arch-hooks.h)
- a generic header (include/linux/mm-arch-hooks.h)

The architecture which need to overwrite a hook as to redefine it in its
header file, while architecture which doesn't need have nothing to do.

The default hooks are defined in the generic header and are used in the case
the architecture is not defining it.

In a next step, mm hooks defined in include/asm-generic/mm_hooks.h should be
moved here.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Suggested-by: Andrew Morton <akpm@linux-foundation.org>
---
 arch/alpha/include/asm/mm-arch-hooks.h      | 15 +++++++++++++++
 arch/arc/include/asm/mm-arch-hooks.h        | 15 +++++++++++++++
 arch/arm/include/asm/mm-arch-hooks.h        | 15 +++++++++++++++
 arch/arm64/include/asm/mm-arch-hooks.h      | 15 +++++++++++++++
 arch/avr32/include/asm/mm-arch-hooks.h      | 15 +++++++++++++++
 arch/blackfin/include/asm/mm-arch-hooks.h   | 15 +++++++++++++++
 arch/c6x/include/asm/mm-arch-hooks.h        | 15 +++++++++++++++
 arch/cris/include/asm/mm-arch-hooks.h       | 15 +++++++++++++++
 arch/frv/include/asm/mm-arch-hooks.h        | 15 +++++++++++++++
 arch/hexagon/include/asm/mm-arch-hooks.h    | 15 +++++++++++++++
 arch/ia64/include/asm/mm-arch-hooks.h       | 15 +++++++++++++++
 arch/m32r/include/asm/mm-arch-hooks.h       | 15 +++++++++++++++
 arch/m68k/include/asm/mm-arch-hooks.h       | 15 +++++++++++++++
 arch/metag/include/asm/mm-arch-hooks.h      | 15 +++++++++++++++
 arch/microblaze/include/asm/mm-arch-hooks.h | 15 +++++++++++++++
 arch/mips/include/asm/mm-arch-hooks.h       | 15 +++++++++++++++
 arch/mn10300/include/asm/mm-arch-hooks.h    | 15 +++++++++++++++
 arch/nios2/include/asm/mm-arch-hooks.h      | 15 +++++++++++++++
 arch/openrisc/include/asm/mm-arch-hooks.h   | 15 +++++++++++++++
 arch/parisc/include/asm/mm-arch-hooks.h     | 15 +++++++++++++++
 arch/powerpc/include/asm/mm-arch-hooks.h    | 15 +++++++++++++++
 arch/s390/include/asm/mm-arch-hooks.h       | 15 +++++++++++++++
 arch/score/include/asm/mm-arch-hooks.h      | 15 +++++++++++++++
 arch/sh/include/asm/mm-arch-hooks.h         | 15 +++++++++++++++
 arch/sparc/include/asm/mm-arch-hooks.h      | 15 +++++++++++++++
 arch/tile/include/asm/mm-arch-hooks.h       | 15 +++++++++++++++
 arch/um/include/asm/mm-arch-hooks.h         | 15 +++++++++++++++
 arch/unicore32/include/asm/mm-arch-hooks.h  | 15 +++++++++++++++
 arch/x86/include/asm/mm-arch-hooks.h        | 15 +++++++++++++++
 arch/xtensa/include/asm/mm-arch-hooks.h     | 15 +++++++++++++++
 include/linux/mm-arch-hooks.h               | 16 ++++++++++++++++
 31 files changed, 466 insertions(+)
 create mode 100644 arch/alpha/include/asm/mm-arch-hooks.h
 create mode 100644 arch/arc/include/asm/mm-arch-hooks.h
 create mode 100644 arch/arm/include/asm/mm-arch-hooks.h
 create mode 100644 arch/arm64/include/asm/mm-arch-hooks.h
 create mode 100644 arch/avr32/include/asm/mm-arch-hooks.h
 create mode 100644 arch/blackfin/include/asm/mm-arch-hooks.h
 create mode 100644 arch/c6x/include/asm/mm-arch-hooks.h
 create mode 100644 arch/cris/include/asm/mm-arch-hooks.h
 create mode 100644 arch/frv/include/asm/mm-arch-hooks.h
 create mode 100644 arch/hexagon/include/asm/mm-arch-hooks.h
 create mode 100644 arch/ia64/include/asm/mm-arch-hooks.h
 create mode 100644 arch/m32r/include/asm/mm-arch-hooks.h
 create mode 100644 arch/m68k/include/asm/mm-arch-hooks.h
 create mode 100644 arch/metag/include/asm/mm-arch-hooks.h
 create mode 100644 arch/microblaze/include/asm/mm-arch-hooks.h
 create mode 100644 arch/mips/include/asm/mm-arch-hooks.h
 create mode 100644 arch/mn10300/include/asm/mm-arch-hooks.h
 create mode 100644 arch/nios2/include/asm/mm-arch-hooks.h
 create mode 100644 arch/openrisc/include/asm/mm-arch-hooks.h
 create mode 100644 arch/parisc/include/asm/mm-arch-hooks.h
 create mode 100644 arch/powerpc/include/asm/mm-arch-hooks.h
 create mode 100644 arch/s390/include/asm/mm-arch-hooks.h
 create mode 100644 arch/score/include/asm/mm-arch-hooks.h
 create mode 100644 arch/sh/include/asm/mm-arch-hooks.h
 create mode 100644 arch/sparc/include/asm/mm-arch-hooks.h
 create mode 100644 arch/tile/include/asm/mm-arch-hooks.h
 create mode 100644 arch/um/include/asm/mm-arch-hooks.h
 create mode 100644 arch/unicore32/include/asm/mm-arch-hooks.h
 create mode 100644 arch/x86/include/asm/mm-arch-hooks.h
 create mode 100644 arch/xtensa/include/asm/mm-arch-hooks.h
 create mode 100644 include/linux/mm-arch-hooks.h

diff --git a/arch/alpha/include/asm/mm-arch-hooks.h b/arch/alpha/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..b07fd862fec3
--- /dev/null
+++ b/arch/alpha/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_ALPHA_MM_ARCH_HOOKS_H
+#define _ASM_ALPHA_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_ALPHA_MM_ARCH_HOOKS_H */
diff --git a/arch/arc/include/asm/mm-arch-hooks.h b/arch/arc/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..c37541c5f8ba
--- /dev/null
+++ b/arch/arc/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_ARC_MM_ARCH_HOOKS_H
+#define _ASM_ARC_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_ARC_MM_ARCH_HOOKS_H */
diff --git a/arch/arm/include/asm/mm-arch-hooks.h b/arch/arm/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..7056660c7cc4
--- /dev/null
+++ b/arch/arm/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_ARM_MM_ARCH_HOOKS_H
+#define _ASM_ARM_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_ARM_MM_ARCH_HOOKS_H */
diff --git a/arch/arm64/include/asm/mm-arch-hooks.h b/arch/arm64/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..562b655f5ba9
--- /dev/null
+++ b/arch/arm64/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_ARM64_MM_ARCH_HOOKS_H
+#define _ASM_ARM64_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_ARM64_MM_ARCH_HOOKS_H */
diff --git a/arch/avr32/include/asm/mm-arch-hooks.h b/arch/avr32/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..145452ffbdad
--- /dev/null
+++ b/arch/avr32/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_AVR32_MM_ARCH_HOOKS_H
+#define _ASM_AVR32_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_AVR32_MM_ARCH_HOOKS_H */
diff --git a/arch/blackfin/include/asm/mm-arch-hooks.h b/arch/blackfin/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..1c5211ec338f
--- /dev/null
+++ b/arch/blackfin/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_BLACKFIN_MM_ARCH_HOOKS_H
+#define _ASM_BLACKFIN_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_BLACKFIN_MM_ARCH_HOOKS_H */
diff --git a/arch/c6x/include/asm/mm-arch-hooks.h b/arch/c6x/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..bb3c4a6ce8e9
--- /dev/null
+++ b/arch/c6x/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_C6X_MM_ARCH_HOOKS_H
+#define _ASM_C6X_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_C6X_MM_ARCH_HOOKS_H */
diff --git a/arch/cris/include/asm/mm-arch-hooks.h b/arch/cris/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..314f774db2b0
--- /dev/null
+++ b/arch/cris/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_CRIS_MM_ARCH_HOOKS_H
+#define _ASM_CRIS_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_CRIS_MM_ARCH_HOOKS_H */
diff --git a/arch/frv/include/asm/mm-arch-hooks.h b/arch/frv/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..51d13a870404
--- /dev/null
+++ b/arch/frv/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_FRV_MM_ARCH_HOOKS_H
+#define _ASM_FRV_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_FRV_MM_ARCH_HOOKS_H */
diff --git a/arch/hexagon/include/asm/mm-arch-hooks.h b/arch/hexagon/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..05e8b939e416
--- /dev/null
+++ b/arch/hexagon/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_HEXAGON_MM_ARCH_HOOKS_H
+#define _ASM_HEXAGON_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_HEXAGON_MM_ARCH_HOOKS_H */
diff --git a/arch/ia64/include/asm/mm-arch-hooks.h b/arch/ia64/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..ab4b5c698322
--- /dev/null
+++ b/arch/ia64/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_IA64_MM_ARCH_HOOKS_H
+#define _ASM_IA64_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_IA64_MM_ARCH_HOOKS_H */
diff --git a/arch/m32r/include/asm/mm-arch-hooks.h b/arch/m32r/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..6d60b4750f41
--- /dev/null
+++ b/arch/m32r/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_M32R_MM_ARCH_HOOKS_H
+#define _ASM_M32R_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_M32R_MM_ARCH_HOOKS_H */
diff --git a/arch/m68k/include/asm/mm-arch-hooks.h b/arch/m68k/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..7e8709bc90ae
--- /dev/null
+++ b/arch/m68k/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_M68K_MM_ARCH_HOOKS_H
+#define _ASM_M68K_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_M68K_MM_ARCH_HOOKS_H */
diff --git a/arch/metag/include/asm/mm-arch-hooks.h b/arch/metag/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..b0072b2eb0de
--- /dev/null
+++ b/arch/metag/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_METAG_MM_ARCH_HOOKS_H
+#define _ASM_METAG_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_METAG_MM_ARCH_HOOKS_H */
diff --git a/arch/microblaze/include/asm/mm-arch-hooks.h b/arch/microblaze/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..5c4065911bda
--- /dev/null
+++ b/arch/microblaze/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_MICROBLAZE_MM_ARCH_HOOKS_H
+#define _ASM_MICROBLAZE_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_MICROBLAZE_MM_ARCH_HOOKS_H */
diff --git a/arch/mips/include/asm/mm-arch-hooks.h b/arch/mips/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..b5609fe8e475
--- /dev/null
+++ b/arch/mips/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_MIPS_MM_ARCH_HOOKS_H
+#define _ASM_MIPS_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_MIPS_MM_ARCH_HOOKS_H */
diff --git a/arch/mn10300/include/asm/mm-arch-hooks.h b/arch/mn10300/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..e2029a652f4c
--- /dev/null
+++ b/arch/mn10300/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_MN10300_MM_ARCH_HOOKS_H
+#define _ASM_MN10300_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_MN10300_MM_ARCH_HOOKS_H */
diff --git a/arch/nios2/include/asm/mm-arch-hooks.h b/arch/nios2/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..d7290dc68558
--- /dev/null
+++ b/arch/nios2/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_NIOS2_MM_ARCH_HOOKS_H
+#define _ASM_NIOS2_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_NIOS2_MM_ARCH_HOOKS_H */
diff --git a/arch/openrisc/include/asm/mm-arch-hooks.h b/arch/openrisc/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..6d33cb555fe1
--- /dev/null
+++ b/arch/openrisc/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_OPENRISC_MM_ARCH_HOOKS_H
+#define _ASM_OPENRISC_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_OPENRISC_MM_ARCH_HOOKS_H */
diff --git a/arch/parisc/include/asm/mm-arch-hooks.h b/arch/parisc/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..654ec63b0ee9
--- /dev/null
+++ b/arch/parisc/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_PARISC_MM_ARCH_HOOKS_H
+#define _ASM_PARISC_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_PARISC_MM_ARCH_HOOKS_H */
diff --git a/arch/powerpc/include/asm/mm-arch-hooks.h b/arch/powerpc/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..63091a19de9f
--- /dev/null
+++ b/arch/powerpc/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_POWERPC_MM_ARCH_HOOKS_H
+#define _ASM_POWERPC_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_POWERPC_MM_ARCH_HOOKS_H */
diff --git a/arch/s390/include/asm/mm-arch-hooks.h b/arch/s390/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..07680b2f3c59
--- /dev/null
+++ b/arch/s390/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_S390_MM_ARCH_HOOKS_H
+#define _ASM_S390_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_S390_MM_ARCH_HOOKS_H */
diff --git a/arch/score/include/asm/mm-arch-hooks.h b/arch/score/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..5e38689f189a
--- /dev/null
+++ b/arch/score/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_SCORE_MM_ARCH_HOOKS_H
+#define _ASM_SCORE_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_SCORE_MM_ARCH_HOOKS_H */
diff --git a/arch/sh/include/asm/mm-arch-hooks.h b/arch/sh/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..18087298b728
--- /dev/null
+++ b/arch/sh/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_SH_MM_ARCH_HOOKS_H
+#define _ASM_SH_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_SH_MM_ARCH_HOOKS_H */
diff --git a/arch/sparc/include/asm/mm-arch-hooks.h b/arch/sparc/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..b89ba44c16f1
--- /dev/null
+++ b/arch/sparc/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_SPARC_MM_ARCH_HOOKS_H
+#define _ASM_SPARC_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_SPARC_MM_ARCH_HOOKS_H */
diff --git a/arch/tile/include/asm/mm-arch-hooks.h b/arch/tile/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..d1709ea774f7
--- /dev/null
+++ b/arch/tile/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_TILE_MM_ARCH_HOOKS_H
+#define _ASM_TILE_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_TILE_MM_ARCH_HOOKS_H */
diff --git a/arch/um/include/asm/mm-arch-hooks.h b/arch/um/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..a7c8b0dfdd4e
--- /dev/null
+++ b/arch/um/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_UM_MM_ARCH_HOOKS_H
+#define _ASM_UM_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_UM_MM_ARCH_HOOKS_H */
diff --git a/arch/unicore32/include/asm/mm-arch-hooks.h b/arch/unicore32/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..4d79a850c509
--- /dev/null
+++ b/arch/unicore32/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_UNICORE32_MM_ARCH_HOOKS_H
+#define _ASM_UNICORE32_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_UNICORE32_MM_ARCH_HOOKS_H */
diff --git a/arch/x86/include/asm/mm-arch-hooks.h b/arch/x86/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..4e881a342236
--- /dev/null
+++ b/arch/x86/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_X86_MM_ARCH_HOOKS_H
+#define _ASM_X86_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_X86_MM_ARCH_HOOKS_H */
diff --git a/arch/xtensa/include/asm/mm-arch-hooks.h b/arch/xtensa/include/asm/mm-arch-hooks.h
new file mode 100644
index 000000000000..d2e5cfd3dd02
--- /dev/null
+++ b/arch/xtensa/include/asm/mm-arch-hooks.h
@@ -0,0 +1,15 @@
+/*
+ * Architecture specific mm hooks
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_XTENSA_MM_ARCH_HOOKS_H
+#define _ASM_XTENSA_MM_ARCH_HOOKS_H
+
+#endif /* _ASM_XTENSA_MM_ARCH_HOOKS_H */
diff --git a/include/linux/mm-arch-hooks.h b/include/linux/mm-arch-hooks.h
new file mode 100644
index 000000000000..63005e367abd
--- /dev/null
+++ b/include/linux/mm-arch-hooks.h
@@ -0,0 +1,16 @@
+/*
+ * Generic mm no-op hooks.
+ *
+ * Copyright (C) 2015, IBM Corporation
+ * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#ifndef _LINUX_MM_ARCH_HOOKS_H
+#define _LINUX_MM_ARCH_HOOKS_H
+
+#include <asm/mm-arch-hooks.h>
+
+#endif /* _LINUX_MM_ARCH_HOOKS_H */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
