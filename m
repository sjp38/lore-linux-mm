Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 650B06B002B
	for <linux-mm@kvack.org>; Sun,  4 Nov 2012 10:08:37 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id i14so2527790dad.14
        for <linux-mm@kvack.org>; Sun, 04 Nov 2012 07:08:36 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [ACPIHP PATCH part3 0/2] enhance ACPI container driver to support hotplug framework
Date: Sun,  4 Nov 2012 23:08:16 +0800
Message-Id: <1352041698-6243-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org

This is the third part of the new ACPI based system device hotplug
framework, which enhances the ACPI container driver to support the
ACPI system device hotplug framework.

For an introduction of the new framework, please refer to:
https://lkml.org/lkml/2012/11/3/143
https://github.com/downloads/jiangliu/linux/ACPI%20Based%20System%20Device%20Dynamic%20Reconfiguration.pdf

And you may pull from:
https://github.com/jiangliu/linux.git acpihp_container

Jiang Liu (2):
  ACPIHP: enhance ACPI container driver to support new hotplug
    framework
  ACPIHP/container: move container.c into drivers/acpi/hotplug

 drivers/acpi/Kconfig             |    7 +-
 drivers/acpi/Makefile            |    1 -
 drivers/acpi/container.c         |  296 --------------------------------------
 drivers/acpi/hotplug/Makefile    |    2 +
 drivers/acpi/hotplug/container.c |  124 ++++++++++++++++
 include/acpi/container.h         |   12 --
 6 files changed, 130 insertions(+), 312 deletions(-)
 delete mode 100644 drivers/acpi/container.c
 create mode 100644 drivers/acpi/hotplug/container.c
 delete mode 100644 include/acpi/container.h

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
