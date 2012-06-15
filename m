Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 9C5AE6B0087
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 09:11:29 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so6467750pbb.14
        for <linux-mm@kvack.org>; Fri, 15 Jun 2012 06:11:28 -0700 (PDT)
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: [PATCH 1/7][TRIVIAL][resend] powerpc: cleanup kernel-doc warning
Date: Fri, 15 Jun 2012 21:10:03 +0800
Message-Id: <1339765810-7161-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: trivial@kernel.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Bjorn Helgaas <bhelgaas@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Christoph Lameter <cl@linux-foundation.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Jesse Barnes <jbarnes@virtuousgeek.org>, Milton Miller <miltonm@bga.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jason Wessel <jason.wessel@windriver.com>, Jan Kiszka <jan.kiszka@siemens.com>, David Howells <dhowells@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan@kernel.org>, Gavin Shan <shangw@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Larry Woodman <lwoodman@redhat.com>, Hugh Dickins <hughd@google.com>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Wanpeng Li <liwp.linux@gmail.com>

From: Wanpeng Li <liwp@linux.vnet.ibm.com>

Warning(arch/powerpc/kernel/pci_of_scan.c:210): Excess function parameter 'node' description in 'of_scan_pci_bridge'
Warning(arch/powerpc/kernel/vio.c:636): No description found for parameter 'desired'
Warning(arch/powerpc/kernel/vio.c:636): Excess function parameter 'new_desired' description in 'vio_cmo_set_dev_desired'
Warning(arch/powerpc/kernel/vio.c:1270): No description found for parameter 'viodrv'
Warning(arch/powerpc/kernel/vio.c:1270): Excess function parameter 'drv' description in '__vio_register_driver'
Warning(arch/powerpc/kernel/vio.c:1289): No description found for parameter 'viodrv'
Warning(arch/powerpc/kernel/vio.c:1289): Excess function parameter 'driver' description in 'vio_unregister_driver'


Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
---
 arch/powerpc/kernel/pci_of_scan.c |    1 -
 arch/powerpc/kernel/vio.c         |    6 +++---
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/arch/powerpc/kernel/pci_of_scan.c b/arch/powerpc/kernel/pci_of_scan.c
index 89dde17..d7dd42b 100644
--- a/arch/powerpc/kernel/pci_of_scan.c
+++ b/arch/powerpc/kernel/pci_of_scan.c
@@ -198,7 +198,6 @@ EXPORT_SYMBOL(of_create_pci_dev);
 
 /**
  * of_scan_pci_bridge - Set up a PCI bridge and scan for child nodes
- * @node: device tree node of bridge
  * @dev: pci_dev structure for the bridge
  *
  * of_scan_bus() calls this routine for each PCI bridge that it finds, and
diff --git a/arch/powerpc/kernel/vio.c b/arch/powerpc/kernel/vio.c
index cb87301..06cbc30 100644
--- a/arch/powerpc/kernel/vio.c
+++ b/arch/powerpc/kernel/vio.c
@@ -625,7 +625,7 @@ struct dma_map_ops vio_dma_mapping_ops = {
  * vio_cmo_set_dev_desired - Set desired entitlement for a device
  *
  * @viodev: struct vio_dev for device to alter
- * @new_desired: new desired entitlement level in bytes
+ * @desired: new desired entitlement level in bytes
  *
  * For use by devices to request a change to their entitlement at runtime or
  * through sysfs.  The desired entitlement level is changed and a balancing
@@ -1262,7 +1262,7 @@ static int vio_bus_remove(struct device *dev)
 
 /**
  * vio_register_driver: - Register a new vio driver
- * @drv:	The vio_driver structure to be registered.
+ * @viodrv:	The vio_driver structure to be registered.
  */
 int __vio_register_driver(struct vio_driver *viodrv, struct module *owner,
 			  const char *mod_name)
@@ -1282,7 +1282,7 @@ EXPORT_SYMBOL(__vio_register_driver);
 
 /**
  * vio_unregister_driver - Remove registration of vio driver.
- * @driver:	The vio_driver struct to be removed form registration
+ * @viodrv:	The vio_driver struct to be removed form registration
  */
 void vio_unregister_driver(struct vio_driver *viodrv)
 {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
