Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 90DCB6B006C
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 19:47:50 -0400 (EDT)
Received: by igcau2 with SMTP id au2so2597926igc.1
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 16:47:50 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0201.hostedemail.com. [216.40.44.201])
        by mx.google.com with ESMTP id lp9si10584267igb.52.2015.03.30.16.47.50
        for <linux-mm@kvack.org>;
        Mon, 30 Mar 2015 16:47:50 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 16/25] include/linux: Use bool function return values of true/false not 1/0
Date: Mon, 30 Mar 2015 16:46:14 -0700
Message-Id: <5edb9453646625a405ef0a642bec0819c0e6c2eb.1427759009.git.joe@perches.com>
In-Reply-To: <cover.1427759009.git.joe@perches.com>
References: <cover.1427759009.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Jason Wessel <jason.wessel@windriver.com>, Samuel Ortiz <sameo@linux.intel.com>, Lee Jones <lee.jones@linaro.org>, Sebastian Reichel <sre@kernel.org>, Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>, David Woodhouse <dwmw2@infradead.org>, Michael Buesch <m@bues.ch>
Cc: linux-ide@vger.kernel.org, kgdb-bugreport@lists.sourceforge.net, linux-mm@kvack.org, linux-pm@vger.kernel.org, netdev@vger.kernel.org

Use the normal return values for bool functions

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/blkdev.h               |  2 +-
 include/linux/ide.h                  |  2 +-
 include/linux/kgdb.h                 |  2 +-
 include/linux/mfd/db8500-prcmu.h     |  2 +-
 include/linux/mm.h                   |  2 +-
 include/linux/power_supply.h         |  8 ++++----
 include/linux/ssb/ssb_driver_extif.h |  2 +-
 include/linux/ssb/ssb_driver_gige.h  | 16 ++++++++--------
 8 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 5d93a66..eced869 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -1591,7 +1591,7 @@ static inline bool blk_integrity_merge_bio(struct request_queue *rq,
 }
 static inline bool blk_integrity_is_initialized(struct gendisk *g)
 {
-	return 0;
+	return false;
 }
 
 #endif /* CONFIG_BLK_DEV_INTEGRITY */
diff --git a/include/linux/ide.h b/include/linux/ide.h
index 93b5ca7..1ba07db 100644
--- a/include/linux/ide.h
+++ b/include/linux/ide.h
@@ -1411,7 +1411,7 @@ void ide_acpi_port_init_devices(ide_hwif_t *);
 extern void ide_acpi_set_state(ide_hwif_t *hwif, int on);
 #else
 static inline int ide_acpi_init(void) { return 0; }
-static inline bool ide_port_acpi(ide_hwif_t *hwif) { return 0; }
+static inline bool ide_port_acpi(ide_hwif_t *hwif) { return false; }
 static inline int ide_acpi_exec_tfs(ide_drive_t *drive) { return 0; }
 static inline void ide_acpi_get_timing(ide_hwif_t *hwif) { ; }
 static inline void ide_acpi_push_timing(ide_hwif_t *hwif) { ; }
diff --git a/include/linux/kgdb.h b/include/linux/kgdb.h
index e465bb1..840f494 100644
--- a/include/linux/kgdb.h
+++ b/include/linux/kgdb.h
@@ -292,7 +292,7 @@ extern bool kgdb_nmi_poll_knock(void);
 #else
 static inline int kgdb_register_nmi_console(void) { return 0; }
 static inline int kgdb_unregister_nmi_console(void) { return 0; }
-static inline bool kgdb_nmi_poll_knock(void) { return 1; }
+static inline bool kgdb_nmi_poll_knock(void) { return true; }
 #endif
 
 extern int kgdb_register_io_module(struct kgdb_io *local_kgdb_io_ops);
diff --git a/include/linux/mfd/db8500-prcmu.h b/include/linux/mfd/db8500-prcmu.h
index 0bd6944..3b06175 100644
--- a/include/linux/mfd/db8500-prcmu.h
+++ b/include/linux/mfd/db8500-prcmu.h
@@ -744,7 +744,7 @@ static inline int db8500_prcmu_load_a9wdog(u8 id, u32 val)
 
 static inline bool db8500_prcmu_is_ac_wake_requested(void)
 {
-	return 0;
+	return false;
 }
 
 static inline int db8500_prcmu_set_arm_opp(u8 opp)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 4a3a385..164108c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -819,7 +819,7 @@ static inline int cpu_pid_to_cpupid(int nid, int pid)
 
 static inline bool cpupid_pid_unset(int cpupid)
 {
-	return 1;
+	return true;
 }
 
 static inline void page_cpupid_reset_last(struct page *page)
diff --git a/include/linux/power_supply.h b/include/linux/power_supply.h
index 75a1dd8..b0b45c7 100644
--- a/include/linux/power_supply.h
+++ b/include/linux/power_supply.h
@@ -350,12 +350,12 @@ static inline bool power_supply_is_amp_property(enum power_supply_property psp)
 	case POWER_SUPPLY_PROP_CURRENT_NOW:
 	case POWER_SUPPLY_PROP_CURRENT_AVG:
 	case POWER_SUPPLY_PROP_CURRENT_BOOT:
-		return 1;
+		return true;
 	default:
 		break;
 	}
 
-	return 0;
+	return false;
 }
 
 static inline bool power_supply_is_watt_property(enum power_supply_property psp)
@@ -378,12 +378,12 @@ static inline bool power_supply_is_watt_property(enum power_supply_property psp)
 	case POWER_SUPPLY_PROP_CONSTANT_CHARGE_VOLTAGE:
 	case POWER_SUPPLY_PROP_CONSTANT_CHARGE_VOLTAGE_MAX:
 	case POWER_SUPPLY_PROP_POWER_NOW:
-		return 1;
+		return true;
 	default:
 		break;
 	}
 
-	return 0;
+	return false;
 }
 
 #endif /* __LINUX_POWER_SUPPLY_H__ */
diff --git a/include/linux/ssb/ssb_driver_extif.h b/include/linux/ssb/ssb_driver_extif.h
index a410e84..5766b6f 100644
--- a/include/linux/ssb/ssb_driver_extif.h
+++ b/include/linux/ssb/ssb_driver_extif.h
@@ -198,7 +198,7 @@ struct ssb_extif {
 
 static inline bool ssb_extif_available(struct ssb_extif *extif)
 {
-	return 0;
+	return false;
 }
 
 static inline
diff --git a/include/linux/ssb/ssb_driver_gige.h b/include/linux/ssb/ssb_driver_gige.h
index 0688472..65f7740 100644
--- a/include/linux/ssb/ssb_driver_gige.h
+++ b/include/linux/ssb/ssb_driver_gige.h
@@ -75,7 +75,7 @@ static inline bool ssb_gige_have_roboswitch(struct pci_dev *pdev)
 	if (dev)
 		return !!(dev->dev->bus->sprom.boardflags_lo &
 			  SSB_GIGE_BFL_ROBOSWITCH);
-	return 0;
+	return false;
 }
 
 /* Returns whether we can only do one DMA at once. */
@@ -85,7 +85,7 @@ static inline bool ssb_gige_one_dma_at_once(struct pci_dev *pdev)
 	if (dev)
 		return ((dev->dev->bus->chip_id == 0x4785) &&
 			(dev->dev->bus->chip_rev < 2));
-	return 0;
+	return false;
 }
 
 /* Returns whether we must flush posted writes. */
@@ -94,7 +94,7 @@ static inline bool ssb_gige_must_flush_posted_writes(struct pci_dev *pdev)
 	struct ssb_gige *dev = pdev_to_ssb_gige(pdev);
 	if (dev)
 		return (dev->dev->bus->chip_id == 0x4785);
-	return 0;
+	return false;
 }
 
 /* Get the device MAC address */
@@ -158,7 +158,7 @@ static inline void ssb_gige_exit(void)
 
 static inline bool pdev_is_ssb_gige_core(struct pci_dev *pdev)
 {
-	return 0;
+	return false;
 }
 static inline struct ssb_gige * pdev_to_ssb_gige(struct pci_dev *pdev)
 {
@@ -166,19 +166,19 @@ static inline struct ssb_gige * pdev_to_ssb_gige(struct pci_dev *pdev)
 }
 static inline bool ssb_gige_is_rgmii(struct pci_dev *pdev)
 {
-	return 0;
+	return false;
 }
 static inline bool ssb_gige_have_roboswitch(struct pci_dev *pdev)
 {
-	return 0;
+	return false;
 }
 static inline bool ssb_gige_one_dma_at_once(struct pci_dev *pdev)
 {
-	return 0;
+	return false;
 }
 static inline bool ssb_gige_must_flush_posted_writes(struct pci_dev *pdev)
 {
-	return 0;
+	return false;
 }
 static inline int ssb_gige_get_macaddr(struct pci_dev *pdev, u8 *macaddr)
 {
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
