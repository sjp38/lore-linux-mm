Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 72F446B00E8
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 21:48:28 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 792E03EE0BD
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 10:48:27 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 55EB145DE60
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 10:48:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 37B4845DE5A
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 10:48:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 285351DB8057
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 10:48:27 +0900 (JST)
Received: from g01jpexchyt24.g01.fujitsu.local (g01jpexchyt24.g01.fujitsu.local [10.128.193.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CC26B1DB8050
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 10:48:26 +0900 (JST)
Message-ID: <506CEADA.9060108@jp.fujitsu.com>
Date: Thu, 4 Oct 2012 10:48:10 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 2/2] acpi,memory-hotplug : call acpi_bus_remo() to remove
 memory device
References: <506CE9F5.8020809@jp.fujitsu.com>
In-Reply-To: <506CE9F5.8020809@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: len.brown@intel.com, wency@cn.fujitsu.com

From: Wen Congyang <wency@cn.fujitsu.com>

The memory device has been ejected and powoffed, so we can call
acpi_bus_remove() to remove the memory device from acpi bus.

CC: Len Brown <len.brown@intel.com>
Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 drivers/acpi/acpi_memhotplug.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-3.6/drivers/acpi/acpi_memhotplug.c
===================================================================
--- linux-3.6.orig/drivers/acpi/acpi_memhotplug.c	2012-10-03 18:17:47.802249170 +0900
+++ linux-3.6/drivers/acpi/acpi_memhotplug.c	2012-10-03 18:17:52.471250299 +0900
@@ -424,8 +424,9 @@ static void acpi_memory_device_notify(ac
 		}
 
 		/*
-		 * TBD: Invoke acpi_bus_remove to cleanup data structures
+		 * Invoke acpi_bus_remove() to remove memory device
 		 */
+		acpi_bus_remove(device, 1);
 
 		/* _EJ0 succeeded; _OST is not necessary */
 		return;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
