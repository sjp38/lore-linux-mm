Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id BBD826B006C
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 03:06:26 -0400 (EDT)
Message-ID: <5009048E.3030606@cn.fujitsu.com>
Date: Fri, 20 Jul 2012 15:11:10 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC PATCH 4/8] memory-hotplug: export the function acpi_bus_remove()
References: <5009038A.4090001@cn.fujitsu.com>
In-Reply-To: <5009038A.4090001@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, Yasuaki ISIMATU <isimatu.yasuaki@jp.fujitsu.com>

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
index c8a1f3b..d5e8d74 100644
--- a/drivers/acpi/scan.c
+++ b/drivers/acpi/scan.c
@@ -1206,7 +1206,7 @@ static int acpi_device_set_context(struct acpi_device *device)
 	return -ENODEV;
 }
 
-static int acpi_bus_remove(struct acpi_device *dev, int rmdevice)
+int acpi_bus_remove(struct acpi_device *dev, int rmdevice)
 {
 	if (!dev)
 		return -EINVAL;
@@ -1228,6 +1228,7 @@ static int acpi_bus_remove(struct acpi_device *dev, int rmdevice)
 
 	return 0;
 }
+EXPORT_SYMBOL(acpi_bus_remove);
 
 static int acpi_add_single_object(struct acpi_device **child,
 				  acpi_handle handle, int type,
diff --git a/include/acpi/acpi_bus.h b/include/acpi/acpi_bus.h
index 9e6e1c6..3eb0ba7 100644
--- a/include/acpi/acpi_bus.h
+++ b/include/acpi/acpi_bus.h
@@ -356,6 +356,7 @@ bool acpi_bus_power_manageable(acpi_handle handle);
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
