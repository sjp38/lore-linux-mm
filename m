Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5FF796B0007
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 17:36:07 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id s7-v6so995183ljh.3
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 14:36:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x14-v6sor1728479ljh.27.2018.10.23.14.36.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Oct 2018 14:36:04 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 05/17] prmem: shorthands for write rare on common types
Date: Wed, 24 Oct 2018 00:34:52 +0300
Message-Id: <20181023213504.28905-6-igor.stoppa@huawei.com>
In-Reply-To: <20181023213504.28905-1-igor.stoppa@huawei.com>
References: <20181023213504.28905-1-igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mimi Zohar <zohar@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, James Morris <jmorris@namei.org>, Michal Hocko <mhocko@kernel.org>, kernel-hardening@lists.openwall.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org
Cc: igor.stoppa@huawei.com, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Wrappers around the basic write rare functionality, addressing several
common data types found in the kernel, allowing to specify the new
values through immediates, like constants and defines.

Note:
The list is not complete and could be expanded.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
CC: Michal Hocko <mhocko@kernel.org>
CC: Vlastimil Babka <vbabka@suse.cz>
CC: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Pavel Tatashin <pasha.tatashin@oracle.com>
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
---
 MAINTAINERS                |   1 +
 include/linux/prmemextra.h | 133 +++++++++++++++++++++++++++++++++++++
 2 files changed, 134 insertions(+)
 create mode 100644 include/linux/prmemextra.h

diff --git a/MAINTAINERS b/MAINTAINERS
index e566c5d09faf..df7221eca160 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -9459,6 +9459,7 @@ M:	Igor Stoppa <igor.stoppa@gmail.com>
 L:	kernel-hardening@lists.openwall.com
 S:	Maintained
 F:	include/linux/prmem.h
+F:	include/linux/prmemextra.h
 F:	mm/prmem.c
 
 MEMORY MANAGEMENT
diff --git a/include/linux/prmemextra.h b/include/linux/prmemextra.h
new file mode 100644
index 000000000000..36995717720e
--- /dev/null
+++ b/include/linux/prmemextra.h
@@ -0,0 +1,133 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * prmemextra.h: Shorthands for write rare of basic data types
+ *
+ * (C) Copyright 2018 Huawei Technologies Co. Ltd.
+ * Author: Igor Stoppa <igor.stoppa@huawei.com>
+ *
+ */
+
+#ifndef _LINUX_PRMEMEXTRA_H
+#define _LINUX_PRMEMEXTRA_H
+
+#include <linux/prmem.h>
+
+/**
+ * wr_char - alters a char in write rare memory
+ * @dst: target for write
+ * @val: new value
+ *
+ * Returns true on success, false otherwise.
+ */
+static __always_inline
+bool wr_char(const char *dst, const char val)
+{
+	return wr_memcpy(dst, &val, sizeof(val));
+}
+
+/**
+ * wr_short - alters a short in write rare memory
+ * @dst: target for write
+ * @val: new value
+ *
+ * Returns true on success, false otherwise.
+ */
+static __always_inline
+bool wr_short(const short *dst, const short val)
+{
+	return wr_memcpy(dst, &val, sizeof(val));
+}
+
+/**
+ * wr_ushort - alters an unsigned short in write rare memory
+ * @dst: target for write
+ * @val: new value
+ *
+ * Returns true on success, false otherwise.
+ */
+static __always_inline
+bool wr_ushort(const unsigned short *dst, const unsigned short val)
+{
+	return wr_memcpy(dst, &val, sizeof(val));
+}
+
+/**
+ * wr_int - alters an int in write rare memory
+ * @dst: target for write
+ * @val: new value
+ *
+ * Returns true on success, false otherwise.
+ */
+static __always_inline
+bool wr_int(const int *dst, const int val)
+{
+	return wr_memcpy(dst, &val, sizeof(val));
+}
+
+/**
+ * wr_uint - alters an unsigned int in write rare memory
+ * @dst: target for write
+ * @val: new value
+ *
+ * Returns true on success, false otherwise.
+ */
+static __always_inline
+bool wr_uint(const unsigned int *dst, const unsigned int val)
+{
+	return wr_memcpy(dst, &val, sizeof(val));
+}
+
+/**
+ * wr_long - alters a long in write rare memory
+ * @dst: target for write
+ * @val: new value
+ *
+ * Returns true on success, false otherwise.
+ */
+static __always_inline
+bool wr_long(const long *dst, const long val)
+{
+	return wr_memcpy(dst, &val, sizeof(val));
+}
+
+/**
+ * wr_ulong - alters an unsigned long in write rare memory
+ * @dst: target for write
+ * @val: new value
+ *
+ * Returns true on success, false otherwise.
+ */
+static __always_inline
+bool wr_ulong(const unsigned long *dst, const unsigned long val)
+{
+	return wr_memcpy(dst, &val, sizeof(val));
+}
+
+/**
+ * wr_longlong - alters a long long in write rare memory
+ * @dst: target for write
+ * @val: new value
+ *
+ * Returns true on success, false otherwise.
+ */
+static __always_inline
+bool wr_longlong(const long long *dst, const long long val)
+{
+	return wr_memcpy(dst, &val, sizeof(val));
+}
+
+/**
+ * wr_ulonglong - alters an unsigned long long in write rare memory
+ * @dst: target for write
+ * @val: new value
+ *
+ * Returns true on success, false otherwise.
+ */
+static __always_inline
+bool wr_ulonglong(const unsigned long long *dst,
+			  const unsigned long long val)
+{
+	return wr_memcpy(dst, &val, sizeof(val));
+}
+
+#endif
-- 
2.17.1
