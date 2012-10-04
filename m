Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 3FD676B00E6
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 21:47:14 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D006B3EE0BC
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 10:47:12 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 84A8D45DEC0
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 10:47:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 682E745DEBA
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 10:47:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B8571DB803F
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 10:47:12 +0900 (JST)
Received: from g01jpexchyt28.g01.fujitsu.local (g01jpexchyt28.g01.fujitsu.local [10.128.193.111])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EB3851DB8041
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 10:47:11 +0900 (JST)
Message-ID: <506CEA90.4020309@jp.fujitsu.com>
Date: Thu, 4 Oct 2012 10:46:56 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 1/2] acpi,memory-hotplug : export the function acpi_bus_remove()
References: <506CE9F5.8020809@jp.fujitsu.com>
In-Reply-To: <506CE9F5.8020809@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: len.brown@intel.com, wency@cn.fujitsu.com

From: Wen Congyang <wency@cn.fujitsu.com>

The function acpi_bus_remove() can remove a acpi device from acpi bus.
When a acpi device is removed, we need to call this function to remove
the acpi device from acpi bus. So export this function.

CC: Len Brown <len.brown@intel.com>
Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 drivers/acpi/scan.c     |    3 ++-
 include/acpi/acpi_bus.h |    1 +
 2 files changed, 3 insertions(+), 1 deletion(-)

Index: linux-3.6/drivers/acpi/scan.c
===================================================================
--- linux-3.6.orig/drivers/acpi/scan.c	2012-10-03 18:16:57.206246798 +0900
+++ linux-3.6/drivers/acpi/scan.c	2012-10-03 18:17:49.974249714 +0900
@@ -1224,7 +1224,7 @@ static int acpi_device_set_context(struc
 	return -ENODEV;
 }
 
-static int acpi_bus_remove(struct acpi_device *dev, int rmdevice)
+int acpi_bus_remove(struct acpi_device *dev, int rmdevice)
 {
 	if (!dev)
 		return -EINVAL;
@@ -1246,6 +1246,7 @@ static int acpi_bus_remove(struct acpi_d
 
 	return 0;
 }
+EXPORT_SYMBOL(acpi_bus_remove);
 
 static int acpi_add_single_object(struct acpi_device **child,
 				  acpi_handle handle, int type,
Index: linux-3.6/include/acpi/acpi_bus.h
===================================================================
--- linux-3.6.orig/include/acpi/acpi_bus.h	2012-10-03 18:16:57.208246800 +0900
+++ linux-3.6/include/acpi/acpi_bus.h	2012-10-03 18:17:49.976249717 +0900
@@ -360,6 +360,7 @@ bool acpi_bus_power_manageable(acpi_hand
 bool acpi_bus_can_wakeup(acpi_handle handle);
 int acpi_power_resource_register_device(struct device *dev, acpi_handle handle);
 void acpi_power_resource_unregister_device(struct device *dev, acpi_handle handle);
+int acpi_bus_remove(struct acpi_device *dev, int rmdevice);
 #ifdef CONFIG_ACPI_PROC_EVENT
 int acpi_bus_generate_proc_event(struct acpi_device *device, u8 type, int data);
 int acpi_bus_generate_proc_event4(const char *class, const char *bid, u8 type, int data);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
