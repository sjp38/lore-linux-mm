Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 210206B0073
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 18:50:46 -0500 (EST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [RFC PATCH v2 02/12] ACPI: Add sys_hotplug.h for system device hotplug framework
Date: Thu, 10 Jan 2013 16:40:20 -0700
Message-Id: <1357861230-29549-3-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1357861230-29549-1-git-send-email-toshi.kani@hp.com>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@sisk.pl, lenb@kernel.org, gregkh@linuxfoundation.org, akpm@linux-foundation.org
Cc: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com, Toshi Kani <toshi.kani@hp.com>

Added include/acpi/sys_hotplug.h, which is ACPI-specific system
device hotplug header and defines the order values of ACPI-specific
handlers.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 include/acpi/sys_hotplug.h |   48 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 48 insertions(+)
 create mode 100644 include/acpi/sys_hotplug.h

diff --git a/include/acpi/sys_hotplug.h b/include/acpi/sys_hotplug.h
new file mode 100644
index 0000000..ad80f61
--- /dev/null
+++ b/include/acpi/sys_hotplug.h
@@ -0,0 +1,48 @@
+/*
+ * sys_hotplug.h - ACPI System device hot-plug framework
+ *
+ * Copyright (C) 2012 Hewlett-Packard Development Company, L.P.
+ *	Toshi Kani <toshi.kani@hp.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ACPI_SYS_HOTPLUG_H
+#define _ACPI_SYS_HOTPLUG_H
+
+#include <linux/list.h>
+#include <linux/device.h>
+#include <linux/sys_hotplug.h>
+
+/*
+ * System device hot-plug operation proceeds in the following order.
+ *   Validate phase -> Execute phase -> Commit phase
+ *
+ * The order values below define the calling sequence of ACPI-specific
+ * handlers for each phase in ascending order.  The order value of
+ * platform-neutral handlers are defined in <linux/sys_hotplug.h>.
+ */
+
+/* Add Validate order values */
+#define SHP_ACPI_BUS_ADD_VALIDATE_ORDER		0	/* must be first */
+
+/* Add Execute order values */
+#define SHP_ACPI_BUS_ADD_EXECUTE_ORDER		10
+#define SHP_ACPI_RES_ADD_EXECUTE_ORDER		20
+
+/* Add Commit order values */
+#define SHP_ACPI_BUS_ADD_COMMIT_ORDER		10
+
+/* Delete Validate order values */
+#define SHP_ACPI_BUS_DEL_VALIDATE_ORDER		0	/* must be first */
+#define SHP_ACPI_RES_DEL_VALIDATE_ORDER		10
+
+/* Delete Execute order values */
+#define SHP_ACPI_BUS_DEL_EXECUTE_ORDER		100
+
+/* Delete Commit order values */
+#define SHP_ACPI_BUS_DEL_COMMIT_ORDER		100
+
+#endif	/* _ACPI_SYS_HOTPLUG_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
