Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 10B7C6B002B
	for <linux-mm@kvack.org>; Sun,  4 Nov 2012 10:24:18 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id rq2so3692039pbb.14
        for <linux-mm@kvack.org>; Sun, 04 Nov 2012 07:24:17 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [ACPIHP PATCH part4 0/9] enhance ACPI processor driver to support new hotplug framework
Date: Sun,  4 Nov 2012 23:23:53 +0800
Message-Id: <1352042642-7306-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org

This is the fourth part of the new ACPI based system device hotplug
framework, which enhances the ACPI processor driver to support the
ACPI system device hotplug framework.

For an introduction of the new framework, please refer to:
https://lkml.org/lkml/2012/11/3/143
https://github.com/downloads/jiangliu/linux/ACPI%20Based%20System%20Device%20Dynamic%20Reconfiguration.pdf

And you may pull from:
https://github.com/jiangliu/linux.git acpihp_processor

This patch set changes the existing ACPI processor driver to support
new hotplug framework as below:
1) remove code to handle hotplug events from processor driver
2) add callbacks to support new hotplug framework
3) some minor fixes/cleanups

Jiang Liu (9):
  ACPI/processor: remove dead code from processor_driver.c
  ACPIHP/processor: reorganize ACPI processor driver for new hotplug
    framework
  ACPIHP/processor: protect accesses to device->driver_data
  ACPIHP/processor: enhance processor driver to support new hotplug
    framework
  CPU: introduce busy flag to temporarily disable CPU online sysfs
    interface
  ACPIHP/processor: reject online/offline requests when doing processor
    hotplug
  ACPI/processor: cache parsed APIC ID in processor driver data
    structure
  ACPI/processor: serialize call to acpi_map/unmap_lsapic
  x86: simplify _acpi_map_lsapic() implementation

 arch/ia64/include/asm/cpu.h     |    2 +-
 arch/ia64/kernel/acpi.c         |   38 +--
 arch/ia64/kernel/topology.c     |   10 +-
 arch/x86/include/asm/cpu.h      |    2 +-
 arch/x86/include/asm/mpspec.h   |    2 +-
 arch/x86/kernel/acpi/boot.c     |   82 +-----
 arch/x86/kernel/apic/apic.c     |    8 +-
 arch/x86/kernel/topology.c      |   10 +-
 drivers/acpi/Kconfig            |   11 +-
 drivers/acpi/internal.h         |    2 +
 drivers/acpi/processor_core.c   |   28 +-
 drivers/acpi/processor_driver.c |  551 ++++++++++++++++++---------------------
 drivers/base/cpu.c              |   22 ++
 drivers/xen/cpu_hotplug.c       |    2 +-
 include/acpi/processor.h        |    3 +
 include/linux/acpi.h            |    2 +-
 include/linux/cpu.h             |    2 +
 17 files changed, 342 insertions(+), 435 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
