Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 728246B0038
	for <linux-mm@kvack.org>; Sat, 18 May 2013 19:27:12 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH 0/5] ACPI / scan / memhotplug: ACPI hotplug rework followup changes
Date: Sun, 19 May 2013 01:29:43 +0200
Message-ID: <2250271.rGYN6WlBxf@vostro.rjw.lan>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ACPI Devel Maling List <linux-acpi@vger.kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Toshi Kani <toshi.kani@hp.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <liuj97@gmail.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, linux-mm@kvack.org

Hi,

This series contains changes that are possible on top of the linux-pm.git
tree's acpi-hotplug branch.  They touch ACPI, driver core and the core memory
hotplug code and the majority of them are about removing code that's not
necessary any more.

Please review and let me know if there's anything wrong with any of them.

[1/5] Drop the struct acpi_device's removal_type field that's not used any more.
[2/5] Pass processor object handle to acpi_bind_one()
[3/5] Replace offline_memory_block() with device_offline().
[4/5] Add second pass of companion offlining to acpi_scan_hot_remove().
[5/5] Drop ACPI memory hotplug code that's not necessary any more.

Thanks,
Rafael


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
