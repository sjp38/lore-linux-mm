Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 910D36B0255
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 09:45:20 -0400 (EDT)
Received: by iofh134 with SMTP id h134so200286274iof.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 06:45:20 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0080.hostedemail.com. [216.40.44.80])
        by mx.google.com with ESMTP id h2si12170005igo.39.2015.09.15.06.45.19
        for <linux-mm@kvack.org>;
        Tue, 15 Sep 2015 06:45:19 -0700 (PDT)
Date: Tue, 15 Sep 2015 09:45:09 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH V3 2/2] debugfs: don't assume sizeof(bool) to be 4 bytes
Message-ID: <20150915094509.46cca84d@gandalf.local.home>
In-Reply-To: <20150915110447.GI6350@linux>
References: <9b705747a138c96c26faee5218f7b47403195b28.1442305897.git.viresh.kumar@linaro.org>
	<27d37898b4be6b9b9f31b90135f8206ca079a868.1442305897.git.viresh.kumar@linaro.org>
	<1442313464.1914.21.camel@sipsolutions.net>
	<20150915110447.GI6350@linux>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viresh Kumar <viresh.kumar@linaro.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Johannes Berg <johannes@sipsolutions.net>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linaro-kernel@lists.linaro.org" <linaro-kernel@lists.linaro.org>, Rafael Wysocki <rjw@rjwysocki.net>, "sboyd@codeaurora.org" <sboyd@codeaurora.org>, "arnd@arndb.de" <arnd@arndb.de>, Mark Brown <broonie@kernel.org>, Akinobu Mita <akinobu.mita@gmail.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, "moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM..." <alsa-devel@alsa-project.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Arik Nemtsov <arik@wizery.com>, "open list:QUALCOMM ATHEROS ATH10K WIRELESS DRIVER" <ath10k@lists.infradead.org>, "open list:QUALCOMM ATHEROS ATH9K WIRELESS
 DRIVER" <ath9k-devel@lists.ath9k.org>, "Altman, Avri" <avri.altman@intel.com>, "open list:B43 WIRELESS DRIVER" <b43-dev@lists.infradead.org>, Borislav Petkov <bp@alien8.de>, Brian Silverman <bsilver16384@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, Charles Keepax <ckeepax@opensource.wolfsonmicro.com>, "Ivgi, Chaya Rachel" <chaya.rachel.ivgi@intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Dmitry Monakhov <dmonakhov@openvz.org>, Doug Thompson <dougthompson@xmission.com>, Eliad Peller <eliad@wizery.com>, "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>, Florian Fainelli <f.fainelli@gmail.com>, Gustavo Padovan <gustavo@padovan.org>, Haggai Eran <haggaie@mellanox.com>, Hariprasad S <hariprasad@chelsio.com>, Ingo Molnar <mingo@kernel.org>, Intel Linux Wireless <ilw@linux.intel.com>, "open list:AMD IOMMU (AMD-VI)" <iommu@lists.linux-foundation.org>, "James E.J. Bottomley" <JBottomley@odin.com>, Jaroslav Kysela <perex@perex.cz>, Jiri Slaby <jirislaby@gmail.com>, Joe Perches <joe@perches.com>, Joerg Roedel <joro@8bytes.org>, Johan Hedberg <johan.hedberg@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Jonathan Corbet <corbet@lwn.net>, Joonsoo Kim <js1304@gmail.com>, Kalle Valo <kvalo@qca.qualcomm.com>, Larry Finger <Larry.Finger@lwfinger.net>, Len Brown <lenb@kernel.org>, Liam Girdwood <lgirdwood@gmail.com>, "open list:ACPI" <linux-acpi@vger.kernel.org>, "moderated list:ARM64 PORT (AARCH64 ARCHITECTURE)" <linux-arm-kernel@lists.infradead.org>, "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:EDAC-CORE" <linux-edac@vger.kernel.org>, open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, "open list:CISCO SCSI
 HBA DRIVER" <linux-scsi@vger.kernel.org>, "open list:ULTRA-WIDEBAND (UWB)
 SUBSYSTEM:" <linux-usb@vger.kernel.org>, "open list:NETWORKING DRIVERS
 (WIRELESS)" <linux-wireless@vger.kernel.org>, "Coelho, Luciano" <luciano.coelho@intel.com>, "Luis R. Rodriguez" <mcgrof@do-not-panic.com>, Marcel Holtmann <marcel@holtmann.org>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Michal Hocko <mhocko@suse.com>, Narsimhulu Musini <nmusini@cisco.com>, "open list:CXGB4 ETHERNET DRIVER (CXGB4)" <netdev@vger.kernel.org>, Nick Kossifidis <mickflemm@gmail.com>, "open
 list:WOLFSON MICROELECTRONICS DRIVERS" <patches@opensource.wolfsonmicro.com>, Peter Zijlstra <peterz@infradead.org>, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Richard Fitzgerald <rf@opensource.wolfsonmicro.com>, Sasha Levin <sasha.levin@oracle.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Sesidhar Baddela <sebaddel@cisco.com>, Stanislaw Gruszka <sgruszka@redhat.com>, Takashi Iwai <tiwai@suse.com>, Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "Winkler,
 Tomas" <tomas.winkler@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Wang Long <long.wanglong@huawei.com>, Will Deacon <will.deacon@arm.com>

On Tue, 15 Sep 2015 16:34:47 +0530
Viresh Kumar <viresh.kumar@linaro.org> wrote:

> Hi Johannes,
> 
> On 15-09-15, 12:37, Johannes Berg wrote:
> > This email has far too many people Cc'ed on it - I don't think vger is
> > even accepting it for that reason. You should probably restrict it to
> > just a few lists when you resubmit.
> 
> Hmm, I know the list is too long and yes its blocked for Admin's
> approval on most of the lists. But that's what was generated by
> get_maintainers and I didn't wanted to miss cc'ing anybody who might
> be able to catch a bug in there.

Then break up the patch. Your Cc list is far too large, I would nack
this patch just for that alone.

Sad part is, you didn't even Cc Linus (which I added). I believe he was
against having bool's in structures before.

Linus, This patch changes a lot of u32s into bools in structures.
What's your take on that?

I added the patch again to the bottom of this email so that Linus may
see it (it was cut from the email I'm replying to).

-- Steve


> 
> > > The problem with current code is that it reads/writes 4 bytes for a
> > > boolean, which will read/update 3 excess bytes following the boolean
> > > variable (when sizeof(bool) is 1 byte). And that can lead to hard to 
> > > fix bugs. It was a nightmare cracking this one.
> > 
> > Unless you're ignoring (or worse, casting away) type warnings, there's
> > no problem/bug at all, you just have to define all the variables used
> > with debugfs_create_bool() as actual u32 variables.
> > 
> > It sounds like you are/were doing something like the following:
> > 
> > bool a, b, c;
> > ...
> > debugfs_create_bool("a", 0600, dir, (u32 *)&a);
> > 
> > which is quite clearly invalid.
> > 
> > Had you properly defined them as u32, as everyone (except for the ACPI
> > case) does, there wouldn't have been any problem:
> > 
> > u32 a, b, c;
> > ...
> > debugfs_create_bool("a", 0600, dir, &a);
> > 
> > 
> > As far as I can tell, there's no bug in the API. It might be a bit
> > strange to have a set of functions called debugfs_create_<type> and
> > then one of them doesn't actually use the type from the name, but
> > that's only a problem if you blindly add casts or ignore the compiler
> > warnings you'd get without casts.
> > 
> > In other words, I think your commit log is extremely misleading. The
> > API perhaps has some inconsistent naming, but all this talk about the
> > sizeof(bool) etc. is simply completely irrelevant since "bool" is not
> > the type used here at all. There's nothing to fix in any of the code
> > you're changing (again, apart from ACPI.)
> > 
> > That said, I don't actually object to this change itself, being able to
> > actually use bool variables with debugfs_create_bool would be nice.
> > However, that shouldn't be documented as a bugfix or anything like
> > that, merely as a cleanup to make the API naming more consistent and to
> > be able to use the (smaller and often more convenient) bool type.
> > 
> > Clearly, it would also lead to less confusion, as we see in ACPI and
> > hear from your OPP code. Note that ACPI is even more confused though
> > since it uses "unsigned long", so it's entirely possible that somebody
> > actually thought about that case and decided not to worry about 64-bit
> > big-endian platforms.
> > 
> > Of course this also means that only the ACPI patch is a candidate for s
> > table.
> 
> Yeah, that's right. Its just a trivial cleanup rather. What about this
> simple changelog instead?
> 
> --
> viresh
> 
> -------------------------8<-------------------------
> 
> Subject: [PATCH] debugfs: Pass bool pointer to debugfs_create_bool()
> 
> Its a bit odd that debugfs_create_bool() takes 'u32 *' as an argument,
> when all it needs is a boolean pointer.
> 
> It would be better to update this API to make it accept 'bool *'
> instead, as that will make it more consistent and often more convenient.
> Over that bool takes just a byte.
> 
> That required updates to all user sites as well in a single commit.
> regmap core was also using debugfs_{read|write}_file_bool(), directly
> and variable types were updated for that to be bool as well.
> 
> Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>



Acked-by: Mark Brown <broonie@kernel.org>
Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
---

V2->V3:
- Moved a bug fix in a separate patch 1/2, so that it can be backported.
- Added Ack from Mark.

 Documentation/filesystems/debugfs.txt      |  2 +-
 arch/arm64/kernel/debug-monitors.c         |  4 ++--
 drivers/acpi/ec.c                          |  2 +-
 drivers/acpi/internal.h                    |  2 +-
 drivers/base/regmap/internal.h             |  6 +++---
 drivers/base/regmap/regcache-lzo.c         |  4 ++--
 drivers/base/regmap/regcache.c             | 24 ++++++++++++------------
 drivers/bluetooth/hci_qca.c                |  4 ++--
 drivers/iommu/amd_iommu_init.c             |  2 +-
 drivers/iommu/amd_iommu_types.h            |  2 +-
 drivers/misc/mei/mei_dev.h                 |  2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h |  4 ++--
 drivers/net/wireless/ath/ath10k/core.h     |  2 +-
 drivers/net/wireless/ath/ath5k/ath5k.h     |  2 +-
 drivers/net/wireless/ath/ath9k/hw.c        |  2 +-
 drivers/net/wireless/ath/ath9k/hw.h        |  4 ++--
 drivers/net/wireless/b43/debugfs.c         | 18 +++++++++---------
 drivers/net/wireless/b43/debugfs.h         |  2 +-
 drivers/net/wireless/b43legacy/debugfs.c   | 10 +++++-----
 drivers/net/wireless/b43legacy/debugfs.h   |  2 +-
 drivers/net/wireless/iwlegacy/common.h     |  6 +++---
 drivers/net/wireless/iwlwifi/mvm/mvm.h     |  6 +++---
 drivers/scsi/snic/snic_trc.c               |  4 ++--
 drivers/scsi/snic/snic_trc.h               |  2 +-
 drivers/uwb/uwb-debug.c                    |  2 +-
 fs/debugfs/file.c                          |  6 +++---
 include/linux/debugfs.h                    |  4 ++--
 include/linux/edac.h                       |  2 +-
 include/linux/fault-inject.h               |  2 +-
 kernel/futex.c                             |  4 ++--
 lib/dma-debug.c                            |  2 +-
 mm/failslab.c                              |  8 ++++----
 mm/page_alloc.c                            |  8 ++++----
 sound/soc/codecs/wm_adsp.h                 |  2 +-
 34 files changed, 79 insertions(+), 79 deletions(-)

diff --git a/Documentation/filesystems/debugfs.txt b/Documentation/filesystems/debugfs.txt
index 463f595733e8..4f45f71149cb 100644
--- a/Documentation/filesystems/debugfs.txt
+++ b/Documentation/filesystems/debugfs.txt
@@ -105,7 +105,7 @@ a variable of type size_t.
 Boolean values can be placed in debugfs with:
 
     struct dentry *debugfs_create_bool(const char *name, umode_t mode,
-				       struct dentry *parent, u32 *value);
+				       struct dentry *parent, bool *value);
 
 A read on the resulting file will yield either Y (for non-zero values) or
 N, followed by a newline.  If written to, it will accept either upper- or
diff --git a/arch/arm64/kernel/debug-monitors.c b/arch/arm64/kernel/debug-monitors.c
index 9b3b62ac9c24..1f4f4e346f38 100644
--- a/arch/arm64/kernel/debug-monitors.c
+++ b/arch/arm64/kernel/debug-monitors.c
@@ -58,7 +58,7 @@ static u32 mdscr_read(void)
  * Allow root to disable self-hosted debug from userspace.
  * This is useful if you want to connect an external JTAG debugger.
  */
-static u32 debug_enabled = 1;
+static bool debug_enabled = true;
 
 static int create_debug_debugfs_entry(void)
 {
@@ -69,7 +69,7 @@ fs_initcall(create_debug_debugfs_entry);
 
 static int __init early_debug_disable(char *buf)
 {
-	debug_enabled = 0;
+	debug_enabled = false;
 	return 0;
 }
 
diff --git a/drivers/acpi/ec.c b/drivers/acpi/ec.c
index 2614a839c60d..f11e17ad7834 100644
--- a/drivers/acpi/ec.c
+++ b/drivers/acpi/ec.c
@@ -1237,7 +1237,7 @@ ec_parse_device(acpi_handle handle, u32 Level, void *context, void **retval)
 	/* Use the global lock for all EC transactions? */
 	tmp = 0;
 	acpi_evaluate_integer(handle, "_GLK", NULL, &tmp);
-	ec->global_lock = tmp;
+	ec->global_lock = !!tmp;
 	ec->handle = handle;
 	return AE_CTRL_TERMINATE;
 }
diff --git a/drivers/acpi/internal.h b/drivers/acpi/internal.h
index 9db196de003c..5a72e2b140fc 100644
--- a/drivers/acpi/internal.h
+++ b/drivers/acpi/internal.h
@@ -138,7 +138,7 @@ struct acpi_ec {
 	unsigned long gpe;
 	unsigned long command_addr;
 	unsigned long data_addr;
-	u32 global_lock;
+	bool global_lock;
 	unsigned long flags;
 	unsigned long reference_count;
 	struct mutex mutex;
diff --git a/drivers/base/regmap/internal.h b/drivers/base/regmap/internal.h
index cc557886ab23..5b907f2c62b9 100644
--- a/drivers/base/regmap/internal.h
+++ b/drivers/base/regmap/internal.h
@@ -122,9 +122,9 @@ struct regmap {
 	unsigned int num_reg_defaults_raw;
 
 	/* if set, only the cache is modified not the HW */
-	u32 cache_only;
+	bool cache_only;
 	/* if set, only the HW is modified not the cache */
-	u32 cache_bypass;
+	bool cache_bypass;
 	/* if set, remember to free reg_defaults_raw */
 	bool cache_free;
 
@@ -132,7 +132,7 @@ struct regmap {
 	const void *reg_defaults_raw;
 	void *cache;
 	/* if set, the cache contains newer data than the HW */
-	u32 cache_dirty;
+	bool cache_dirty;
 	/* if set, the HW registers are known to match map->reg_defaults */
 	bool no_sync_defaults;
 
diff --git a/drivers/base/regmap/regcache-lzo.c b/drivers/base/regmap/regcache-lzo.c
index 2d53f6f138e1..736e0d378567 100644
--- a/drivers/base/regmap/regcache-lzo.c
+++ b/drivers/base/regmap/regcache-lzo.c
@@ -355,9 +355,9 @@ static int regcache_lzo_sync(struct regmap *map, unsigned int min,
 		if (ret > 0 && val == map->reg_defaults[ret].def)
 			continue;
 
-		map->cache_bypass = 1;
+		map->cache_bypass = true;
 		ret = _regmap_write(map, i, val);
-		map->cache_bypass = 0;
+		map->cache_bypass = false;
 		if (ret)
 			return ret;
 		dev_dbg(map->dev, "Synced register %#x, value %#x\n",
diff --git a/drivers/base/regmap/regcache.c b/drivers/base/regmap/regcache.c
index 6f8a13ec32a4..4c07802986b2 100644
--- a/drivers/base/regmap/regcache.c
+++ b/drivers/base/regmap/regcache.c
@@ -54,11 +54,11 @@ static int regcache_hw_init(struct regmap *map)
 		return -ENOMEM;
 
 	if (!map->reg_defaults_raw) {
-		u32 cache_bypass = map->cache_bypass;
+		bool cache_bypass = map->cache_bypass;
 		dev_warn(map->dev, "No cache defaults, reading back from HW\n");
 
 		/* Bypass the cache access till data read from HW*/
-		map->cache_bypass = 1;
+		map->cache_bypass = true;
 		tmp_buf = kmalloc(map->cache_size_raw, GFP_KERNEL);
 		if (!tmp_buf) {
 			ret = -ENOMEM;
@@ -285,9 +285,9 @@ static int regcache_default_sync(struct regmap *map, unsigned int min,
 		if (!regcache_reg_needs_sync(map, reg, val))
 			continue;
 
-		map->cache_bypass = 1;
+		map->cache_bypass = true;
 		ret = _regmap_write(map, reg, val);
-		map->cache_bypass = 0;
+		map->cache_bypass = false;
 		if (ret) {
 			dev_err(map->dev, "Unable to sync register %#x. %d\n",
 				reg, ret);
@@ -315,7 +315,7 @@ int regcache_sync(struct regmap *map)
 	int ret = 0;
 	unsigned int i;
 	const char *name;
-	unsigned int bypass;
+	bool bypass;
 
 	BUG_ON(!map->cache_ops);
 
@@ -333,7 +333,7 @@ int regcache_sync(struct regmap *map)
 	map->async = true;
 
 	/* Apply any patch first */
-	map->cache_bypass = 1;
+	map->cache_bypass = true;
 	for (i = 0; i < map->patch_regs; i++) {
 		ret = _regmap_write(map, map->patch[i].reg, map->patch[i].def);
 		if (ret != 0) {
@@ -342,7 +342,7 @@ int regcache_sync(struct regmap *map)
 			goto out;
 		}
 	}
-	map->cache_bypass = 0;
+	map->cache_bypass = false;
 
 	if (map->cache_ops->sync)
 		ret = map->cache_ops->sync(map, 0, map->max_register);
@@ -384,7 +384,7 @@ int regcache_sync_region(struct regmap *map, unsigned int min,
 {
 	int ret = 0;
 	const char *name;
-	unsigned int bypass;
+	bool bypass;
 
 	BUG_ON(!map->cache_ops);
 
@@ -637,11 +637,11 @@ static int regcache_sync_block_single(struct regmap *map, void *block,
 		if (!regcache_reg_needs_sync(map, regtmp, val))
 			continue;
 
-		map->cache_bypass = 1;
+		map->cache_bypass = true;
 
 		ret = _regmap_write(map, regtmp, val);
 
-		map->cache_bypass = 0;
+		map->cache_bypass = false;
 		if (ret != 0) {
 			dev_err(map->dev, "Unable to sync register %#x. %d\n",
 				regtmp, ret);
@@ -668,14 +668,14 @@ static int regcache_sync_block_raw_flush(struct regmap *map, const void **data,
 	dev_dbg(map->dev, "Writing %zu bytes for %d registers from 0x%x-0x%x\n",
 		count * val_bytes, count, base, cur - map->reg_stride);
 
-	map->cache_bypass = 1;
+	map->cache_bypass = true;
 
 	ret = _regmap_raw_write(map, base, *data, count * val_bytes);
 	if (ret)
 		dev_err(map->dev, "Unable to sync registers %#x-%#x. %d\n",
 			base, cur - map->reg_stride, ret);
 
-	map->cache_bypass = 0;
+	map->cache_bypass = false;
 
 	*data = NULL;
 
diff --git a/drivers/bluetooth/hci_qca.c b/drivers/bluetooth/hci_qca.c
index 6b9b91267959..509477681661 100644
--- a/drivers/bluetooth/hci_qca.c
+++ b/drivers/bluetooth/hci_qca.c
@@ -80,8 +80,8 @@ struct qca_data {
 	spinlock_t hci_ibs_lock;	/* HCI_IBS state lock	*/
 	u8 tx_ibs_state;	/* HCI_IBS transmit side power state*/
 	u8 rx_ibs_state;	/* HCI_IBS receive side power state */
-	u32 tx_vote;		/* Clock must be on for TX */
-	u32 rx_vote;		/* Clock must be on for RX */
+	bool tx_vote;		/* Clock must be on for TX */
+	bool rx_vote;		/* Clock must be on for RX */
 	struct timer_list tx_idle_timer;
 	u32 tx_idle_delay;
 	struct timer_list wake_retrans_timer;
diff --git a/drivers/iommu/amd_iommu_init.c b/drivers/iommu/amd_iommu_init.c
index 5ef347a13cb5..c59314523f4c 100644
--- a/drivers/iommu/amd_iommu_init.c
+++ b/drivers/iommu/amd_iommu_init.c
@@ -138,7 +138,7 @@ u16 amd_iommu_last_bdf;			/* largest PCI device id we have
 					   to handle */
 LIST_HEAD(amd_iommu_unity_map);		/* a list of required unity mappings
 					   we find in ACPI */
-u32 amd_iommu_unmap_flush;		/* if true, flush on every unmap */
+bool amd_iommu_unmap_flush;		/* if true, flush on every unmap */
 
 LIST_HEAD(amd_iommu_list);		/* list of all AMD IOMMUs in the
 					   system */
diff --git a/drivers/iommu/amd_iommu_types.h b/drivers/iommu/amd_iommu_types.h
index f65908841be0..861550a1ad1f 100644
--- a/drivers/iommu/amd_iommu_types.h
+++ b/drivers/iommu/amd_iommu_types.h
@@ -674,7 +674,7 @@ extern unsigned long *amd_iommu_pd_alloc_bitmap;
  * If true, the addresses will be flushed on unmap time, not when
  * they are reused
  */
-extern u32 amd_iommu_unmap_flush;
+extern bool amd_iommu_unmap_flush;
 
 /* Smallest max PASID supported by any IOMMU in the system */
 extern u32 amd_iommu_max_pasid;
diff --git a/drivers/misc/mei/mei_dev.h b/drivers/misc/mei/mei_dev.h
index e25ee16c658e..d74b6aa8ae27 100644
--- a/drivers/misc/mei/mei_dev.h
+++ b/drivers/misc/mei/mei_dev.h
@@ -528,7 +528,7 @@ struct mei_device {
 	DECLARE_BITMAP(host_clients_map, MEI_CLIENTS_MAX);
 	unsigned long me_client_index;
 
-	u32 allow_fixed_address;
+	bool allow_fixed_address;
 
 	struct mei_cl wd_cl;
 	enum mei_wd_states wd_state;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index fa0c7b54ec7a..5384f999c24b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -767,8 +767,8 @@ struct adapter {
 	bool tid_release_task_busy;
 
 	struct dentry *debugfs_root;
-	u32 use_bd;     /* Use SGE Back Door intfc for reading SGE Contexts */
-	u32 trace_rss;	/* 1 implies that different RSS flit per filter is
+	bool use_bd;     /* Use SGE Back Door intfc for reading SGE Contexts */
+	bool trace_rss;	/* 1 implies that different RSS flit per filter is
 			 * used per filter else if 0 default RSS flit is
 			 * used for all 4 filters.
 			 */
diff --git a/drivers/net/wireless/ath/ath10k/core.h b/drivers/net/wireless/ath/ath10k/core.h
index 12542144fe12..b6a08177b6ee 100644
--- a/drivers/net/wireless/ath/ath10k/core.h
+++ b/drivers/net/wireless/ath/ath10k/core.h
@@ -680,7 +680,7 @@ struct ath10k {
 	bool monitor_started;
 	unsigned int filter_flags;
 	unsigned long dev_flags;
-	u32 dfs_block_radar_events;
+	bool dfs_block_radar_events;
 
 	/* protected by conf_mutex */
 	bool radar_enabled;
diff --git a/drivers/net/wireless/ath/ath5k/ath5k.h b/drivers/net/wireless/ath/ath5k/ath5k.h
index fa6e89e5c421..ba12f7f4061d 100644
--- a/drivers/net/wireless/ath/ath5k/ath5k.h
+++ b/drivers/net/wireless/ath/ath5k/ath5k.h
@@ -1367,7 +1367,7 @@ struct ath5k_hw {
 	u8			ah_retry_long;
 	u8			ah_retry_short;
 
-	u32			ah_use_32khz_clock;
+	bool			ah_use_32khz_clock;
 
 	u8			ah_coverage_class;
 	bool			ah_ack_bitrate_high;
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index 1dd0339de372..8823fadada89 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -385,7 +385,7 @@ static void ath9k_hw_init_config(struct ath_hw *ah)
 
 	ah->config.dma_beacon_response_time = 1;
 	ah->config.sw_beacon_response_time = 6;
-	ah->config.cwm_ignore_extcca = 0;
+	ah->config.cwm_ignore_extcca = false;
 	ah->config.analog_shiftreg = 1;
 
 	ah->config.rx_intr_mitigation = true;
diff --git a/drivers/net/wireless/ath/ath9k/hw.h b/drivers/net/wireless/ath/ath9k/hw.h
index e8454db17634..52971b48ab6a 100644
--- a/drivers/net/wireless/ath/ath9k/hw.h
+++ b/drivers/net/wireless/ath/ath9k/hw.h
@@ -332,14 +332,14 @@ enum ath9k_hw_hang_checks {
 struct ath9k_ops_config {
 	int dma_beacon_response_time;
 	int sw_beacon_response_time;
-	u32 cwm_ignore_extcca;
+	bool cwm_ignore_extcca;
 	u32 pcie_waen;
 	u8 analog_shiftreg;
 	u32 ofdm_trig_low;
 	u32 ofdm_trig_high;
 	u32 cck_trig_high;
 	u32 cck_trig_low;
-	u32 enable_paprd;
+	bool enable_paprd;
 	int serialize_regmode;
 	bool rx_intr_mitigation;
 	bool tx_intr_mitigation;
diff --git a/drivers/net/wireless/b43/debugfs.c b/drivers/net/wireless/b43/debugfs.c
index e807bd930647..b4bcd94aff6c 100644
--- a/drivers/net/wireless/b43/debugfs.c
+++ b/drivers/net/wireless/b43/debugfs.c
@@ -676,15 +676,15 @@ static void b43_add_dynamic_debug(struct b43_wldev *dev)
 		e->dyn_debug_dentries[id] = d;		\
 				} while (0)
 
-	add_dyn_dbg("debug_xmitpower", B43_DBG_XMITPOWER, 0);
-	add_dyn_dbg("debug_dmaoverflow", B43_DBG_DMAOVERFLOW, 0);
-	add_dyn_dbg("debug_dmaverbose", B43_DBG_DMAVERBOSE, 0);
-	add_dyn_dbg("debug_pwork_fast", B43_DBG_PWORK_FAST, 0);
-	add_dyn_dbg("debug_pwork_stop", B43_DBG_PWORK_STOP, 0);
-	add_dyn_dbg("debug_lo", B43_DBG_LO, 0);
-	add_dyn_dbg("debug_firmware", B43_DBG_FIRMWARE, 0);
-	add_dyn_dbg("debug_keys", B43_DBG_KEYS, 0);
-	add_dyn_dbg("debug_verbose_stats", B43_DBG_VERBOSESTATS, 0);
+	add_dyn_dbg("debug_xmitpower", B43_DBG_XMITPOWER, false);
+	add_dyn_dbg("debug_dmaoverflow", B43_DBG_DMAOVERFLOW, false);
+	add_dyn_dbg("debug_dmaverbose", B43_DBG_DMAVERBOSE, false);
+	add_dyn_dbg("debug_pwork_fast", B43_DBG_PWORK_FAST, false);
+	add_dyn_dbg("debug_pwork_stop", B43_DBG_PWORK_STOP, false);
+	add_dyn_dbg("debug_lo", B43_DBG_LO, false);
+	add_dyn_dbg("debug_firmware", B43_DBG_FIRMWARE, false);
+	add_dyn_dbg("debug_keys", B43_DBG_KEYS, false);
+	add_dyn_dbg("debug_verbose_stats", B43_DBG_VERBOSESTATS, false);
 
 #undef add_dyn_dbg
 }
diff --git a/drivers/net/wireless/b43/debugfs.h b/drivers/net/wireless/b43/debugfs.h
index 50517b801cb4..d05377745011 100644
--- a/drivers/net/wireless/b43/debugfs.h
+++ b/drivers/net/wireless/b43/debugfs.h
@@ -68,7 +68,7 @@ struct b43_dfsentry {
 	u32 shm32read_addr_next;
 
 	/* Enabled/Disabled list for the dynamic debugging features. */
-	u32 dyn_debug[__B43_NR_DYNDBG];
+	bool dyn_debug[__B43_NR_DYNDBG];
 	/* Dentries for the dynamic debugging entries. */
 	struct dentry *dyn_debug_dentries[__B43_NR_DYNDBG];
 };
diff --git a/drivers/net/wireless/b43legacy/debugfs.c b/drivers/net/wireless/b43legacy/debugfs.c
index 1965edb765a2..090910ea259e 100644
--- a/drivers/net/wireless/b43legacy/debugfs.c
+++ b/drivers/net/wireless/b43legacy/debugfs.c
@@ -369,11 +369,11 @@ static void b43legacy_add_dynamic_debug(struct b43legacy_wldev *dev)
 		e->dyn_debug_dentries[id] = d;		\
 				} while (0)
 
-	add_dyn_dbg("debug_xmitpower", B43legacy_DBG_XMITPOWER, 0);
-	add_dyn_dbg("debug_dmaoverflow", B43legacy_DBG_DMAOVERFLOW, 0);
-	add_dyn_dbg("debug_dmaverbose", B43legacy_DBG_DMAVERBOSE, 0);
-	add_dyn_dbg("debug_pwork_fast", B43legacy_DBG_PWORK_FAST, 0);
-	add_dyn_dbg("debug_pwork_stop", B43legacy_DBG_PWORK_STOP, 0);
+	add_dyn_dbg("debug_xmitpower", B43legacy_DBG_XMITPOWER, false);
+	add_dyn_dbg("debug_dmaoverflow", B43legacy_DBG_DMAOVERFLOW, false);
+	add_dyn_dbg("debug_dmaverbose", B43legacy_DBG_DMAVERBOSE, false);
+	add_dyn_dbg("debug_pwork_fast", B43legacy_DBG_PWORK_FAST, false);
+	add_dyn_dbg("debug_pwork_stop", B43legacy_DBG_PWORK_STOP, false);
 
 #undef add_dyn_dbg
 }
diff --git a/drivers/net/wireless/b43legacy/debugfs.h b/drivers/net/wireless/b43legacy/debugfs.h
index ae3b0d0fa849..9ee32158b947 100644
--- a/drivers/net/wireless/b43legacy/debugfs.h
+++ b/drivers/net/wireless/b43legacy/debugfs.h
@@ -47,7 +47,7 @@ struct b43legacy_dfsentry {
 	struct b43legacy_txstatus_log txstatlog;
 
 	/* Enabled/Disabled list for the dynamic debugging features. */
-	u32 dyn_debug[__B43legacy_NR_DYNDBG];
+	bool dyn_debug[__B43legacy_NR_DYNDBG];
 	/* Dentries for the dynamic debugging entries. */
 	struct dentry *dyn_debug_dentries[__B43legacy_NR_DYNDBG];
 };
diff --git a/drivers/net/wireless/iwlegacy/common.h b/drivers/net/wireless/iwlegacy/common.h
index 5b972798bdff..ce52cf114fde 100644
--- a/drivers/net/wireless/iwlegacy/common.h
+++ b/drivers/net/wireless/iwlegacy/common.h
@@ -1425,9 +1425,9 @@ struct il_priv {
 #endif				/* CONFIG_IWLEGACY_DEBUGFS */
 
 	struct work_struct txpower_work;
-	u32 disable_sens_cal;
-	u32 disable_chain_noise_cal;
-	u32 disable_tx_power_cal;
+	bool disable_sens_cal;
+	bool disable_chain_noise_cal;
+	bool disable_tx_power_cal;
 	struct work_struct run_time_calib_work;
 	struct timer_list stats_periodic;
 	struct timer_list watchdog;
diff --git a/drivers/net/wireless/iwlwifi/mvm/mvm.h b/drivers/net/wireless/iwlwifi/mvm/mvm.h
index b95a07ec9e36..72e8a03a5293 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mvm.h
+++ b/drivers/net/wireless/iwlwifi/mvm/mvm.h
@@ -649,7 +649,7 @@ struct iwl_mvm {
 	const struct iwl_fw_bcast_filter *bcast_filters;
 #ifdef CONFIG_IWLWIFI_DEBUGFS
 	struct {
-		u32 override; /* u32 for debugfs_create_bool */
+		bool override;
 		struct iwl_bcast_filter_cmd cmd;
 	} dbgfs_bcast_filtering;
 #endif
@@ -673,7 +673,7 @@ struct iwl_mvm {
 	bool disable_power_off;
 	bool disable_power_off_d3;
 
-	u32 scan_iter_notif_enabled; /* must be u32 for debugfs_create_bool */
+	bool scan_iter_notif_enabled;
 
 	struct debugfs_blob_wrapper nvm_hw_blob;
 	struct debugfs_blob_wrapper nvm_sw_blob;
@@ -729,7 +729,7 @@ struct iwl_mvm {
 	int n_nd_channels;
 	bool net_detect;
 #ifdef CONFIG_IWLWIFI_DEBUGFS
-	u32 d3_wake_sysassert; /* must be u32 for debugfs_create_bool */
+	bool d3_wake_sysassert;
 	bool d3_test_active;
 	bool store_d3_resume_sram;
 	void *d3_resume_sram;
diff --git a/drivers/scsi/snic/snic_trc.c b/drivers/scsi/snic/snic_trc.c
index 28a40a7ade38..f00ebf4717e0 100644
--- a/drivers/scsi/snic/snic_trc.c
+++ b/drivers/scsi/snic/snic_trc.c
@@ -148,7 +148,7 @@ snic_trc_init(void)
 
 	trc->max_idx = (tbuf_sz / SNIC_TRC_ENTRY_SZ);
 	trc->rd_idx = trc->wr_idx = 0;
-	trc->enable = 1;
+	trc->enable = true;
 	SNIC_INFO("Trace Facility Enabled.\n Trace Buffer SZ %lu Pages.\n",
 		  tbuf_sz / PAGE_SIZE);
 	ret = 0;
@@ -169,7 +169,7 @@ snic_trc_free(void)
 {
 	struct snic_trc *trc = &snic_glob->trc;
 
-	trc->enable = 0;
+	trc->enable = false;
 	snic_trc_debugfs_term();
 
 	if (trc->buf) {
diff --git a/drivers/scsi/snic/snic_trc.h b/drivers/scsi/snic/snic_trc.h
index 427faee5f97e..b37f8867bfde 100644
--- a/drivers/scsi/snic/snic_trc.h
+++ b/drivers/scsi/snic/snic_trc.h
@@ -45,7 +45,7 @@ struct snic_trc {
 	u32	max_idx;		/* Max Index into trace buffer */
 	u32	rd_idx;
 	u32	wr_idx;
-	u32	enable;			/* Control Variable for Tracing */
+	bool	enable;			/* Control Variable for Tracing */
 
 	struct dentry *trc_enable;	/* debugfs file object */
 	struct dentry *trc_file;
diff --git a/drivers/uwb/uwb-debug.c b/drivers/uwb/uwb-debug.c
index 0b1e5a9449b5..991374b13571 100644
--- a/drivers/uwb/uwb-debug.c
+++ b/drivers/uwb/uwb-debug.c
@@ -55,7 +55,7 @@
 struct uwb_dbg {
 	struct uwb_pal pal;
 
-	u32 accept;
+	bool accept;
 	struct list_head rsvs;
 
 	struct dentry *root_d;
diff --git a/fs/debugfs/file.c b/fs/debugfs/file.c
index 6c55ade071c3..b70c20fae502 100644
--- a/fs/debugfs/file.c
+++ b/fs/debugfs/file.c
@@ -439,7 +439,7 @@ ssize_t debugfs_read_file_bool(struct file *file, char __user *user_buf,
 			       size_t count, loff_t *ppos)
 {
 	char buf[3];
-	u32 *val = file->private_data;
+	bool *val = file->private_data;
 
 	if (*val)
 		buf[0] = 'Y';
@@ -457,7 +457,7 @@ ssize_t debugfs_write_file_bool(struct file *file, const char __user *user_buf,
 	char buf[32];
 	size_t buf_size;
 	bool bv;
-	u32 *val = file->private_data;
+	bool *val = file->private_data;
 
 	buf_size = min(count, (sizeof(buf)-1));
 	if (copy_from_user(buf, user_buf, buf_size))
@@ -503,7 +503,7 @@ static const struct file_operations fops_bool = {
  * code.
  */
 struct dentry *debugfs_create_bool(const char *name, umode_t mode,
-				   struct dentry *parent, u32 *value)
+				   struct dentry *parent, bool *value)
 {
 	return debugfs_create_file(name, mode, parent, value, &fops_bool);
 }
diff --git a/include/linux/debugfs.h b/include/linux/debugfs.h
index 9beb636b97eb..8321fe3058d6 100644
--- a/include/linux/debugfs.h
+++ b/include/linux/debugfs.h
@@ -92,7 +92,7 @@ struct dentry *debugfs_create_size_t(const char *name, umode_t mode,
 struct dentry *debugfs_create_atomic_t(const char *name, umode_t mode,
 				     struct dentry *parent, atomic_t *value);
 struct dentry *debugfs_create_bool(const char *name, umode_t mode,
-				  struct dentry *parent, u32 *value);
+				  struct dentry *parent, bool *value);
 
 struct dentry *debugfs_create_blob(const char *name, umode_t mode,
 				  struct dentry *parent,
@@ -243,7 +243,7 @@ static inline struct dentry *debugfs_create_atomic_t(const char *name, umode_t m
 
 static inline struct dentry *debugfs_create_bool(const char *name, umode_t mode,
 						 struct dentry *parent,
-						 u32 *value)
+						 bool *value)
 {
 	return ERR_PTR(-ENODEV);
 }
diff --git a/include/linux/edac.h b/include/linux/edac.h
index da3b72e95db3..7c6b7ba55589 100644
--- a/include/linux/edac.h
+++ b/include/linux/edac.h
@@ -772,7 +772,7 @@ struct mem_ctl_info {
 #ifdef CONFIG_EDAC_DEBUG
 	struct dentry *debugfs;
 	u8 fake_inject_layer[EDAC_MAX_LAYERS];
-	u32 fake_inject_ue;
+	bool fake_inject_ue;
 	u16 fake_inject_count;
 #endif
 };
diff --git a/include/linux/fault-inject.h b/include/linux/fault-inject.h
index 798fad9e420d..3159a7dba034 100644
--- a/include/linux/fault-inject.h
+++ b/include/linux/fault-inject.h
@@ -18,7 +18,7 @@ struct fault_attr {
 	atomic_t times;
 	atomic_t space;
 	unsigned long verbose;
-	u32 task_filter;
+	bool task_filter;
 	unsigned long stacktrace_depth;
 	unsigned long require_start;
 	unsigned long require_end;
diff --git a/kernel/futex.c b/kernel/futex.c
index 6e443efc65f4..395b967841b4 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -267,10 +267,10 @@ static struct futex_hash_bucket *futex_queues;
 static struct {
 	struct fault_attr attr;
 
-	u32 ignore_private;
+	bool ignore_private;
 } fail_futex = {
 	.attr = FAULT_ATTR_INITIALIZER,
-	.ignore_private = 0,
+	.ignore_private = false,
 };
 
 static int __init setup_fail_futex(char *str)
diff --git a/lib/dma-debug.c b/lib/dma-debug.c
index dace71fe41f7..fcb65d2a0b94 100644
--- a/lib/dma-debug.c
+++ b/lib/dma-debug.c
@@ -100,7 +100,7 @@ static LIST_HEAD(free_entries);
 static DEFINE_SPINLOCK(free_entries_lock);
 
 /* Global disable flag - will be set in case of an error */
-static u32 global_disable __read_mostly;
+static bool global_disable __read_mostly;
 
 /* Early initialization disable flag, set at the end of dma_debug_init */
 static bool dma_debug_initialized __read_mostly;
diff --git a/mm/failslab.c b/mm/failslab.c
index fefaabaab76d..98fb490311eb 100644
--- a/mm/failslab.c
+++ b/mm/failslab.c
@@ -3,12 +3,12 @@
 
 static struct {
 	struct fault_attr attr;
-	u32 ignore_gfp_wait;
-	int cache_filter;
+	bool ignore_gfp_wait;
+	bool cache_filter;
 } failslab = {
 	.attr = FAULT_ATTR_INITIALIZER,
-	.ignore_gfp_wait = 1,
-	.cache_filter = 0,
+	.ignore_gfp_wait = true,
+	.cache_filter = false,
 };
 
 bool should_failslab(size_t size, gfp_t gfpflags, unsigned long cache_flags)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 48aaf7b9f253..805bbad2e24e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2159,13 +2159,13 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 static struct {
 	struct fault_attr attr;
 
-	u32 ignore_gfp_highmem;
-	u32 ignore_gfp_wait;
+	bool ignore_gfp_highmem;
+	bool ignore_gfp_wait;
 	u32 min_order;
 } fail_page_alloc = {
 	.attr = FAULT_ATTR_INITIALIZER,
-	.ignore_gfp_wait = 1,
-	.ignore_gfp_highmem = 1,
+	.ignore_gfp_wait = true,
+	.ignore_gfp_highmem = true,
 	.min_order = 1,
 };
 
diff --git a/sound/soc/codecs/wm_adsp.h b/sound/soc/codecs/wm_adsp.h
index 579a6350fb01..2d117cf0e953 100644
--- a/sound/soc/codecs/wm_adsp.h
+++ b/sound/soc/codecs/wm_adsp.h
@@ -53,7 +53,7 @@ struct wm_adsp {
 
 	int fw;
 	int fw_ver;
-	u32 running;
+	bool running;
 
 	struct list_head ctl_list;
 
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
