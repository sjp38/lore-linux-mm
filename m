Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 8F7716B0074
	for <linux-mm@kvack.org>; Tue, 28 Aug 2012 05:59:55 -0400 (EDT)
From: wency@cn.fujitsu.com
Subject: [RFC v8 PATCH 06/20] memory-hotplug: export the function acpi_bus_remove()
Date: Tue, 28 Aug 2012 18:00:13 +0800
Message-Id: <1346148027-24468-7-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1346148027-24468-1-git-send-email-wency@cn.fujitsu.com>
References: <1346148027-24468-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Wen Congyang <wency@cn.fujitsu.com>

From: Wen Congyang <wency@cn.fujitsu.com>

The function acpi_bus_remove() can remove a acpi device from acpi device.
When a acpi device is removed, we need to call this function to remove
the acpi device from acpi bus. So export this function.

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 drivers/acpi/scan.c     |    3 ++-
 include/acpi/acpi_bus.h |    1 +
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/acpi/scan.c b/drivers/acpi/scan.c
index d1ecca2..1cefc34 100644
--- a/drivers/acpi/scan.c
+++ b/drivers/acpi/scan.c
@@ -1224,7 +1224,7 @@ static int acpi_device_set_context(struct acpi_device *device)
 	return -ENODEV;
 }
 
-static int acpi_bus_remove(struct acpi_device *dev, int rmdevice)
+int acpi_bus_remove(struct acpi_device *dev, int rmdevice)
 {
 	if (!dev)
 		return -EINVAL;
@@ -1246,6 +1246,7 @@ static int acpi_bus_remove(struct acpi_device *dev, int rmdevice)
 
 	return 0;
 }
+EXPORT_SYMBOL(acpi_bus_remove);
 
 static int acpi_add_single_object(struct acpi_device **child,
 				  acpi_handle handle, int type,
diff --git a/include/acpi/acpi_bus.h b/include/acpi/acpi_bus.h
index bde976e..2ccf109 100644
--- a/include/acpi/acpi_bus.h
+++ b/include/acpi/acpi_bus.h
@@ -360,6 +360,7 @@ bool acpi_bus_power_manageable(acpi_handle handle);
 bool acpi_bus_can_wakeup(acpi_handle handle);
 int acpi_power_resource_register_device(struct device *dev, acpi_handle handle);
 void acpi_power_resource_unregister_device(struct device *dev, acpi_handle handle);
+int acpi_bus_remove(struct acpi_device *dev, int rmdevice);
 #ifdef CONFIG_ACPI_PROC_EVENT
 int acpi_bus_generate_proc_event(struct acpi_device *device, u8 type, int data);
 int acpi_bus_generate_proc_event4(const char *class, const char *bid, u8 type, int data);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
