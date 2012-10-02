Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 60D686B005D
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 08:48:24 -0400 (EDT)
Date: Tue, 2 Oct 2012 14:48:14 +0200
From: Thierry Reding <thierry.reding@avionic-design.de>
Subject: Re: CMA broken in next-20120926
Message-ID: <20121002124814.GA31316@avionic-0098.mockup.avionic-design.de>
References: <20120928083722.GM3429@suse.de>
 <50656459.70309@ti.com>
 <20120928102728.GN3429@suse.de>
 <20120928103207.GA22811@avionic-0098.mockup.avionic-design.de>
 <20120928103815.GA15219@avionic-0098.mockup.avionic-design.de>
 <20120928105113.GA18883@avionic-0098.mockup.avionic-design.de>
 <20120928110712.GB29125@suse.de>
 <20120928113924.GA25342@avionic-0098.mockup.avionic-design.de>
 <20120928124332.GC29125@suse.de>
 <20121001142428.GA2798@avionic-0098.mockup.avionic-design.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="H1spWtNR+x+ondvy"
Content-Disposition: inline
In-Reply-To: <20121001142428.GA2798@avionic-0098.mockup.avionic-design.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Ujfalusi <peter.ujfalusi@ti.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>


--H1spWtNR+x+ondvy
Content-Type: multipart/mixed; boundary="y0ulUmNC+osPPQO6"
Content-Disposition: inline


--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Oct 01, 2012 at 04:24:29PM +0200, Thierry Reding wrote:
> On Fri, Sep 28, 2012 at 01:43:32PM +0100, Mel Gorman wrote:
> > On Fri, Sep 28, 2012 at 01:39:24PM +0200, Thierry Reding wrote:
> > > On Fri, Sep 28, 2012 at 12:07:12PM +0100, Mel Gorman wrote:
> > > > On Fri, Sep 28, 2012 at 12:51:13PM +0200, Thierry Reding wrote:
> > > > > On Fri, Sep 28, 2012 at 12:38:15PM +0200, Thierry Reding wrote:
> > > > > > On Fri, Sep 28, 2012 at 12:32:07PM +0200, Thierry Reding wrote:
> > > > > > > On Fri, Sep 28, 2012 at 11:27:28AM +0100, Mel Gorman wrote:
> > > > > > > > On Fri, Sep 28, 2012 at 11:48:25AM +0300, Peter Ujfalusi wr=
ote:
> > > > > > > > > Hi,
> > > > > > > > >=20
> > > > > > > > > On 09/28/2012 11:37 AM, Mel Gorman wrote:
> > > > > > > > > >> I hope this patch fixes the bug. If this patch fixes t=
he problem
> > > > > > > > > >> but has some problem about description or someone has =
better idea,
> > > > > > > > > >> feel free to modify and resend to akpm, Please.
> > > > > > > > > >>
> > > > > > > > > >=20
> > > > > > > > > > A full revert is overkill. Can the following patch be t=
ested as a
> > > > > > > > > > potential replacement please?
> > > > > > > > > >=20
> > > > > > > > > > ---8<---
> > > > > > > > > > mm: compaction: Iron out isolate_freepages_block() and =
isolate_freepages_range() -fix1
> > > > > > > > > >=20
> > > > > > > > > > CMA is reported to be broken in next-20120926. Minchan =
Kim pointed out
> > > > > > > > > > that this was due to nr_scanned !=3D total_isolated in =
the case of CMA
> > > > > > > > > > because PageBuddy pages are one scan but many isolation=
s in CMA. This
> > > > > > > > > > patch should address the problem.
> > > > > > > > > >=20
> > > > > > > > > > This patch is a fix for
> > > > > > > > > > mm-compaction-acquire-the-zone-lock-as-late-as-possible=
-fix-2.patch
> > > > > > > > > >=20
> > > > > > > > > > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > > > > > > > >=20
> > > > > > > > > linux-next + this patch alone also works for me.
> > > > > > > > >=20
> > > > > > > > > Tested-by: Peter Ujfalusi <peter.ujfalusi@ti.com>
> > > > > > > >=20
> > > > > > > > Thanks Peter. I expect it also works for Thierry as I expec=
t you were
> > > > > > > > suffering the same problem but obviously confirmation of th=
at would be nice.
> > > > > > >=20
> > > > > > > I've been running a few tests and indeed this solves the obvi=
ous problem
> > > > > > > that the coherent pool cannot be created at boot (which in tu=
rn caused
> > > > > > > the ethernet adapter to fail on Tegra).
> > > > > > >=20
> > > > > > > However I've been working on the Tegra DRM driver, which uses=
 CMA to
> > > > > > > allocate large chunks of framebuffer memory and these are now=
 failing.
> > > > > > > I'll need to check if Minchan's patch solves that problem as =
well.
> > > > > >=20
> > > > > > Indeed, with Minchan's patch the DRM can allocate the framebuff=
er
> > > > > > without a problem. Something else must be wrong then.
> > > > >=20
> > > > > However, depending on the size of the allocation it also happens =
with
> > > > > Minchan's patch. What I see is this:
> > > > >=20
> > > > > [   60.736729] alloc_contig_range test_pages_isolated(1e900, 1f0e=
9) failed
> > > > > [   60.743572] alloc_contig_range test_pages_isolated(1ea00, 1f1e=
9) failed
> > > > > [   60.750424] alloc_contig_range test_pages_isolated(1ea00, 1f2e=
9) failed
> > > > > [   60.757239] alloc_contig_range test_pages_isolated(1ec00, 1f3e=
9) failed
> > > > > [   60.764066] alloc_contig_range test_pages_isolated(1ec00, 1f4e=
9) failed
> > > > > [   60.770893] alloc_contig_range test_pages_isolated(1ec00, 1f5e=
9) failed
> > > > > [   60.777698] alloc_contig_range test_pages_isolated(1ec00, 1f6e=
9) failed
> > > > > [   60.784526] alloc_contig_range test_pages_isolated(1f000, 1f7e=
9) failed
> > > > > [   60.791148] drm tegra: Failed to alloc buffer: 8294400
> > > > >=20
> > > > > I'm pretty sure this did work before next-20120926.
> > > > >=20
> > > >=20
> > > > Can you double check this please?
> > > >=20
> > > > This is a separate bug but may be related to the same series. Howev=
er, CMA should
> > > > be ignoring the "skip" hints and because it's sync compaction it sh=
ould
> > > > not be exiting due to lock contention. Maybe Marek will spot it.
> > >=20
> > > I've written a small test module that tries to allocate growing blocks
> > > of contiguous memory and it seems like with your patch this always fa=
ils
> > > at 8 MiB.
> >=20
> > You earlier said it also happens with Minchan's but your statment here
> > is less clear. Does Minchan's also fail on the 8MiB boundary? Second,
> > did the test module work with next-20120926?
>=20
> The cmatest module that I use tries to allocate blocks from 4 KiB to 256
> MiB (in increments of powers of two). With next-20120926 this always
> fails at 8 MiB, independent of the CMA size setting (though I didn't
> test setting the CMA size to <=3D 8 MiB, I assumed that would make the 8
> MiB allocation fail anyway). Note that I had to apply the attached patch
> which fixes a build failure on next-20120926. I believe that Mark Brown
> posted a similar fix a few days ago. I'm also attaching a log from the
> module's test run. There's also an interesting page allocation failure
> at the very end of that log which I have not seen with next-20120925.
>=20
> I've run the same tests on next-20120925 with the CMA size set to 256
> MiB and only the 256 MiB allocation fails. This is normal since there
> are other modules that already allocate smaller buffers from CMA, so a
> whole 256 MiB won't be available.
>=20
> Vanilla 3.6-rc6 shows the same behaviour as next-20120925. I will try
> 3.6-rc7 next since that's what next-20120926 is based on. If that
> succeeds I'll try to bisect between 3.6-rc7 and next-20120926 to find
> the culprit, but that will probably take some more time as I need to
> apply at least one other commit on top to get the board to boot at all.
>=20
> So this really isn't all that new, but I just wanted to confirm my
> results from last week. We'll see if bisection shows up something
> interesting.

I just finished bisecting this and git reports:

	3750280f8bd0ed01753a72542756a8c82ab27933 is the first bad commit

I'm attaching the complete bisection log and a diff of all the changes
applied on top of the bad commit to make it compile and run on my board.
Most of the patch is probably not important, though. There are two hunks
which have the pageblock changes I already posted an two other hunks
with the patch you posted earlier.

I hope this helps. If you want me to run any other tests, please let me
know.

Thierry

--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline; filename="bisect.log"

# bad: [0ea37fe67df08c854d0a39c8ff094c363eda0bb6] Add linux-next specific files for 20120926
# good: [979570e02981d4a8fc20b3cc8fd651856c98ee9d] Linux 3.6-rc7
git bisect start 'next-20120926' 'v3.6-rc7'
# good: [e5f962c00ba860a6e442a2c2b53bd256332a8a3c] Merge remote-tracking branch 'spi-mb/spi-next'
git bisect good e5f962c00ba860a6e442a2c2b53bd256332a8a3c
# good: [d2ec64078851952bbd347cd41119c49a80877c4a] Merge remote-tracking branch 'usb/usb-next'
git bisect good d2ec64078851952bbd347cd41119c49a80877c4a
# good: [71d5f924a70be51a8005a11277ee032797b644f5] Merge remote-tracking branch 'gpio-lw/for-next'
git bisect good 71d5f924a70be51a8005a11277ee032797b644f5
# good: [71d5f924a70be51a8005a11277ee032797b644f5] Merge remote-tracking branch 'gpio-lw/for-next'
git bisect good 71d5f924a70be51a8005a11277ee032797b644f5
# good: [058aa5321c0521c89b030b4d5e63d82a4973dd5f] Merge branch 'late/kirkwood' into for-next
git bisect good 058aa5321c0521c89b030b4d5e63d82a4973dd5f
# good: [c32532bac72e1261fcc9e3f5d6edf0a7f30e0f45] drivers/scsi/atp870u.c: fix bad use of udelay
git bisect good c32532bac72e1261fcc9e3f5d6edf0a7f30e0f45
# bad: [ab032478bf2d6bdd6815669a5d2e64b4d753ca43] sections: fix section conflicts in drivers/macintosh
git bisect bad ab032478bf2d6bdd6815669a5d2e64b4d753ca43
# bad: [ab032478bf2d6bdd6815669a5d2e64b4d753ca43] sections: fix section conflicts in drivers/macintosh
git bisect bad ab032478bf2d6bdd6815669a5d2e64b4d753ca43
# good: [9735f3816804ac2c4d694d5b69412275acd453ef] rbtree: remove prior augmented rbtree implementation
git bisect good 9735f3816804ac2c4d694d5b69412275acd453ef
# good: [030585452e07d6642b60ed157b637fa905926fb0] Revert "mm: have order > 0 compaction start off where it left"
git bisect good 030585452e07d6642b60ed157b637fa905926fb0
# good: [030585452e07d6642b60ed157b637fa905926fb0] Revert "mm: have order > 0 compaction start off where it left"
git bisect good 030585452e07d6642b60ed157b637fa905926fb0
# bad: [03ad92e89a2c77bbefe442abe00745192b28d8e5] mm: move all mmu notifier invocations to be done outside the PT lock
git bisect bad 03ad92e89a2c77bbefe442abe00745192b28d8e5
# bad: [ec2e5c22ffcec23861fdde919f30ddf6abe7abf9] memcg: trivial fixes for Documentation/cgroups/memory.txt
git bisect bad ec2e5c22ffcec23861fdde919f30ddf6abe7abf9
# bad: [0ef8ed15fb52b8a9fd0af217a46044e3c4eb5b30] memory-hotplug: don't replace lowmem pages with highmem
git bisect bad 0ef8ed15fb52b8a9fd0af217a46044e3c4eb5b30
# bad: [b1bda30b420402da621f0ca7d844668fb66c9c64] mm/hugetlb.c: remove duplicate inclusion of header file
git bisect bad b1bda30b420402da621f0ca7d844668fb66c9c64
# bad: [8686ddfe5d23e7b0f3e250d979b9734aac61b64a] mm: compaction: Restart compaction from near where it left off
git bisect bad 8686ddfe5d23e7b0f3e250d979b9734aac61b64a
# bad: [8686ddfe5d23e7b0f3e250d979b9734aac61b64a] mm: compaction: Restart compaction from near where it left off
git bisect bad 8686ddfe5d23e7b0f3e250d979b9734aac61b64a
# bad: [3750280f8bd0ed01753a72542756a8c82ab27933] mm: compaction: cache if a pageblock was scanned and no pages were isolated
git bisect bad 3750280f8bd0ed01753a72542756a8c82ab27933

--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline; filename="bisect.patch"
Content-Transfer-Encoding: quoted-printable

diff --git a/arch/arm/boot/dts/tegra20-harmony.dts b/arch/arm/boot/dts/tegr=
a20-harmony.dts
index c3ef1ad..e701d3d 100644
--- a/arch/arm/boot/dts/tegra20-harmony.dts
+++ b/arch/arm/boot/dts/tegra20-harmony.dts
@@ -7,7 +7,11 @@
 	compatible =3D "nvidia,harmony", "nvidia,tegra20";
=20
 	memory {
-		reg =3D <0x00000000 0x40000000>;
+		reg =3D <0x00000000 0x20000000>;
+	};
+
+	chosen {
+		bootargs =3D "console=3DttyS0,115200n8 root=3DLABEL=3Dboot:/rootfs.img r=
o ignore_loglevel earlyprintk";
 	};
=20
 	pinmux {
diff --git a/arch/arm/configs/tegra_defconfig b/arch/arm/configs/tegra_defc=
onfig
index e2184f6..aefd42c 100644
--- a/arch/arm/configs/tegra_defconfig
+++ b/arch/arm/configs/tegra_defconfig
@@ -24,7 +24,6 @@ CONFIG_EFI_PARTITION=3Dy
 # CONFIG_IOSCHED_DEADLINE is not set
 # CONFIG_IOSCHED_CFQ is not set
 CONFIG_ARCH_TEGRA=3Dy
-CONFIG_GPIO_PCA953X=3Dy
 CONFIG_ARCH_TEGRA_2x_SOC=3Dy
 CONFIG_ARCH_TEGRA_3x_SOC=3Dy
 CONFIG_TEGRA_PCI=3Dy
@@ -80,6 +79,14 @@ CONFIG_RFKILL_GPIO=3Dy
 CONFIG_DEVTMPFS=3Dy
 CONFIG_DEVTMPFS_MOUNT=3Dy
 # CONFIG_FIRMWARE_IN_KERNEL is not set
+CONFIG_CMA=3Dy
+CONFIG_CMA_DEBUG=3Dy
+CONFIG_CMA_SIZE_MBYTES=3D256
+CONFIG_CMA_TEST=3Dm
+CONFIG_MTD=3Dm
+CONFIG_MTD_CHAR=3Dm
+CONFIG_MTD_M25P80=3Dm
+CONFIG_MTD_NAND=3Dm
 CONFIG_PROC_DEVICETREE=3Dy
 CONFIG_BLK_DEV_LOOP=3Dy
 CONFIG_AD525X_DPOT=3Dy
@@ -112,71 +119,51 @@ CONFIG_SERIAL_OF_PLATFORM=3Dy
 # CONFIG_HW_RANDOM is not set
 CONFIG_I2C=3Dy
 # CONFIG_I2C_COMPAT is not set
-CONFIG_I2C_MUX=3Dy
-CONFIG_I2C_MUX_PINCTRL=3Dy
+CONFIG_I2C_CHARDEV=3Dy
+CONFIG_I2C_OCORES=3Dm
 CONFIG_I2C_TEGRA=3Dy
 CONFIG_SPI=3Dy
-CONFIG_SPI_TEGRA=3Dy
-CONFIG_GPIO_PCA953X_IRQ=3Dy
+CONFIG_GPIO_SYSFS=3Dy
 CONFIG_GPIO_TPS6586X=3Dy
-CONFIG_GPIO_TPS65910=3Dy
 CONFIG_POWER_SUPPLY=3Dy
 CONFIG_BATTERY_SBS=3Dy
 CONFIG_SENSORS_LM90=3Dy
 CONFIG_MFD_TPS6586X=3Dy
-CONFIG_MFD_TPS65910=3Dy
-CONFIG_MFD_MAX8907=3Dy
 CONFIG_REGULATOR=3Dy
 CONFIG_REGULATOR_FIXED_VOLTAGE=3Dy
 CONFIG_REGULATOR_VIRTUAL_CONSUMER=3Dy
 CONFIG_REGULATOR_GPIO=3Dy
-CONFIG_REGULATOR_MAX8907=3Dy
-CONFIG_REGULATOR_TPS62360=3Dy
 CONFIG_REGULATOR_TPS6586X=3Dy
-CONFIG_REGULATOR_TPS65910=3Dy
-CONFIG_MEDIA_SUPPORT=3Dy
-CONFIG_MEDIA_CAMERA_SUPPORT=3Dy
-CONFIG_MEDIA_USB_SUPPORT=3Dy
-CONFIG_USB_VIDEO_CLASS=3Dm
+CONFIG_DRM=3Dm
+CONFIG_FB=3Dm
+CONFIG_FIRMWARE_EDID=3Dy
+CONFIG_FB_MODE_HELPERS=3Dy
+CONFIG_FB_TILEBLITTING=3Dy
+CONFIG_BACKLIGHT_LCD_SUPPORT=3Dy
+# CONFIG_LCD_CLASS_DEVICE is not set
+# CONFIG_BACKLIGHT_GENERIC is not set
+CONFIG_BACKLIGHT_PWM=3Dm
+CONFIG_LOGO=3Dy
 CONFIG_SOUND=3Dy
 CONFIG_SND=3Dy
 # CONFIG_SND_SUPPORT_OLD_API is not set
 # CONFIG_SND_DRIVERS is not set
+# CONFIG_SND_PCI is not set
 # CONFIG_SND_ARM is not set
 # CONFIG_SND_SPI is not set
 # CONFIG_SND_USB is not set
 CONFIG_SND_SOC=3Dy
-CONFIG_SND_SOC_TEGRA=3Dy
-CONFIG_SND_SOC_TEGRA_WM8753=3Dy
-CONFIG_SND_SOC_TEGRA_WM8903=3Dy
-CONFIG_SND_SOC_TEGRA_TRIMSLICE=3Dy
-CONFIG_SND_SOC_TEGRA_ALC5632=3Dy
 CONFIG_USB=3Dy
 CONFIG_USB_EHCI_HCD=3Dy
 CONFIG_USB_EHCI_TEGRA=3Dy
-CONFIG_USB_ACM=3Dy
-CONFIG_USB_WDM=3Dy
 CONFIG_USB_STORAGE=3Dy
 CONFIG_MMC=3Dy
 CONFIG_MMC_BLOCK_MINORS=3D16
 CONFIG_MMC_SDHCI=3Dy
 CONFIG_MMC_SDHCI_PLTFM=3Dy
 CONFIG_MMC_SDHCI_TEGRA=3Dy
-CONFIG_NEW_LEDS=3Dy
-CONFIG_LEDS_CLASS=3Dy
-CONFIG_LEDS_GPIO=3Dy
-CONFIG_LEDS_TRIGGERS=3Dy
-CONFIG_LEDS_TRIGGER_GPIO=3Dy
 CONFIG_RTC_CLASS=3Dy
-CONFIG_RTC_INTF_SYSFS=3Dy
-CONFIG_RTC_INTF_PROC=3Dy
-CONFIG_RTC_INTF_DEV=3Dy
-CONFIG_RTC_DRV_MAX8907=3Dy
-CONFIG_RTC_DRV_TPS65910=3Dy
-CONFIG_RTC_DRV_EM3027=3Dy
 CONFIG_RTC_DRV_TEGRA=3Dy
-CONFIG_DMADEVICES=3Dy
-CONFIG_TEGRA20_APB_DMA=3Dy
 CONFIG_STAGING=3Dy
 CONFIG_SENSORS_ISL29018=3Dy
 CONFIG_SENSORS_ISL29028=3Dy
@@ -184,14 +171,12 @@ CONFIG_SENSORS_AK8975=3Dy
 CONFIG_MFD_NVEC=3Dy
 CONFIG_KEYBOARD_NVEC=3Dy
 CONFIG_SERIO_NVEC_PS2=3Dy
-CONFIG_NVEC_POWER=3Dy
-CONFIG_NVEC_PAZ00=3Dy
 CONFIG_TEGRA_IOMMU_GART=3Dy
 CONFIG_TEGRA_IOMMU_SMMU=3Dy
 CONFIG_MEMORY=3Dy
 CONFIG_IIO=3Dy
 CONFIG_PWM=3Dy
-CONFIG_PWM_TEGRA=3Dy
+CONFIG_PWM_TEGRA=3Dm
 CONFIG_EXT2_FS=3Dy
 CONFIG_EXT2_FS_XATTR=3Dy
 CONFIG_EXT2_FS_POSIX_ACL=3Dy
@@ -204,14 +189,16 @@ CONFIG_EXT4_FS=3Dy
 # CONFIG_DNOTIFY is not set
 CONFIG_VFAT_FS=3Dy
 CONFIG_TMPFS=3Dy
-CONFIG_TMPFS_POSIX_ACL=3Dy
-CONFIG_NFS_FS=3Dy
-CONFIG_ROOT_NFS=3Dy
+CONFIG_SQUASHFS=3Dy
+CONFIG_SQUASHFS_XATTR=3Dy
+CONFIG_SQUASHFS_LZO=3Dy
+CONFIG_SQUASHFS_XZ=3Dy
 CONFIG_NLS_CODEPAGE_437=3Dy
 CONFIG_NLS_ISO8859_1=3Dy
 CONFIG_PRINTK_TIME=3Dy
 CONFIG_MAGIC_SYSRQ=3Dy
 CONFIG_DEBUG_FS=3Dy
+CONFIG_DEBUG_SECTION_MISMATCH=3Dy
 CONFIG_DETECT_HUNG_TASK=3Dy
 CONFIG_SCHEDSTATS=3Dy
 CONFIG_TIMER_STATS=3Dy
diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
index 08b4c52..431d387 100644
--- a/drivers/base/Kconfig
+++ b/drivers/base/Kconfig
@@ -280,6 +280,9 @@ config CMA_AREAS
=20
 	  If unsure, leave the default value "7".
=20
+config CMA_TEST
+	tristate "CMA test module"
+
 endif
=20
 endmenu
diff --git a/drivers/base/Makefile b/drivers/base/Makefile
index 5aa2d70..c4b2a97 100644
--- a/drivers/base/Makefile
+++ b/drivers/base/Makefile
@@ -7,6 +7,7 @@ obj-y			:=3D core.o bus.o dd.o syscore.o \
 			   topology.o
 obj-$(CONFIG_DEVTMPFS)	+=3D devtmpfs.o
 obj-$(CONFIG_CMA) +=3D dma-contiguous.o
+obj-$(CONFIG_CMA_TEST)	+=3D cmatest.o
 obj-y			+=3D power/
 obj-$(CONFIG_HAS_DMA)	+=3D dma-mapping.o
 obj-$(CONFIG_HAVE_GENERIC_DMA_COHERENT) +=3D dma-coherent.o
diff --git a/drivers/base/cmatest.c b/drivers/base/cmatest.c
new file mode 100644
index 0000000..23d8f7f
--- /dev/null
+++ b/drivers/base/cmatest.c
@@ -0,0 +1,38 @@
+#ifdef CONFIG_CMA_DEBUG
+#  ifndef DEBUG
+#    define DEBUG
+#  endif
+#endif
+
+#include <linux/dma-mapping.h>
+#include <linux/module.h>
+
+static int cmatest_init(void)
+{
+	unsigned int i;
+
+	for (i =3D 12; i <=3D 28; i++) {
+		dma_addr_t phys;
+		void *ptr;
+
+		ptr =3D dma_alloc_writecombine(NULL, 1 << i, &phys, GFP_KERNEL);
+		if (ptr) {
+			pr_debug("successfully allocated %u bytes\n", 1 << i);
+			dma_free_writecombine(NULL, 1 << i, ptr, phys);
+		} else {
+			pr_debug("failed to allocate %u bytes\n", 1 << i);
+		}
+	}
+
+	return 0;
+}
+module_init(cmatest_init);
+
+static void cmatest_exit(void)
+{
+}
+module_exit(cmatest_exit);
+
+MODULE_AUTHOR("Thierry Reding <thierry.reding@avionic-design.de>");
+MODULE_DESCRIPTION("Contiguous Memory Allocator test module");
+MODULE_LICENSE("GPL v2");
diff --git a/include/linux/audit.h b/include/linux/audit.h
index 50faabe..a7a7db9 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -528,7 +528,7 @@ static inline void audit_ptrace(struct task_struct *t)
 extern unsigned int audit_serial(void);
 extern int auditsc_get_stamp(struct audit_context *ctx,
 			      struct timespec *t, unsigned int *serial);
-extern int audit_set_loginuid(kuid_t loginuid);
+extern int  audit_set_loginuid(kuid_t loginuid);
 #define audit_get_loginuid(t) ((t)->loginuid)
 #define audit_get_sessionid(t) ((t)->sessionid)
 extern void audit_log_task_context(struct audit_buffer *ab);
@@ -627,97 +627,38 @@ static inline void audit_mmap_fd(int fd, int flags)
 extern int audit_n_rules;
 extern int audit_signals;
 #else /* CONFIG_AUDITSYSCALL */
-static inline int audit_alloc(struct task_struct *task)
-{
-	return 0;
-}
-static inline void audit_free(struct task_struct *task)
-{ }
-static inline void audit_syscall_entry(int arch, int major, unsigned long =
a0,
-				       unsigned long a1, unsigned long a2,
-				       unsigned long a3)
-{ }
-static inline void audit_syscall_exit(void *pt_regs)
-{ }
-static inline int audit_dummy_context(void)
-{
-	return 1;
-}
-static inline void audit_getname(const char *name)
-{ }
-static inline void audit_putname(const char *name)
-{ }
-static inline void __audit_inode(const char *name, const struct dentry *de=
ntry)
-{ }
-static inline void __audit_inode_child(const struct dentry *dentry,
-					const struct inode *parent)
-{ }
-static inline void audit_inode(const char *name, const struct dentry *dent=
ry)
-{ }
-static inline void audit_inode_child(const struct dentry *dentry,
-				     const struct inode *parent)
-{ }
-static inline void audit_core_dumps(long signr)
-{ }
-static inline void __audit_seccomp(unsigned long syscall, long signr, int =
code)
-{ }
-static inline void audit_seccomp(unsigned long syscall, long signr, int co=
de)
-{ }
-static inline int auditsc_get_stamp(struct audit_context *ctx,
-			      struct timespec *t, unsigned int *serial)
-{
-	return 0;
-}
-static inline int audit_get_loginuid(struct task_struct *tsk)
-{
-	return INVALID_UID;
-}
-static inline void audit_log_task_context(struct audit_buffer *ab)
-{ }
-static inline void audit_log_task_info(struct audit_buffer *ab,
-				       struct task_struct *tsk)
-{ }
-static inline void audit_ipc_obj(struct kern_ipc_perm *ipcp)
-{ }
-static inline void audit_ipc_set_perm(unsigned long qbytes, uid_t uid,
-					gid_t gid, umode_t mode)
-{ }
-static inline int audit_bprm(struct linux_binprm *bprm)
-{
-	return 0;
-}
-static inline void audit_socketcall(int nargs, unsigned long *args)
-{ }
-static inline void audit_fd_pair(int fd1, int fd2)
-{ }
-static inline int audit_sockaddr(int len, void *addr)
-{
-	return 0;
-}
-static inline void audit_mq_open(int oflag, umode_t mode, struct mq_attr *=
attr)
-{ }
-static inline void audit_mq_sendrecv(mqd_t mqdes, size_t msg_len,
-				     unsigned int msg_prio,
-				     const struct timespec *abs_timeout)
-{ }
-static inline void audit_mq_notify(mqd_t mqdes,
-				   const struct sigevent *notification)
-{ }
-static inline void audit_mq_getsetattr(mqd_t mqdes, struct mq_attr *mqstat)
-{ }
-static inline int audit_log_bprm_fcaps(struct linux_binprm *bprm,
-				       const struct cred *new,
-				       const struct cred *old)
-{
-	return 0;
-}
-static inline void audit_log_capset(pid_t pid, const struct cred *new,
-				   const struct cred *old)
-{ }
-static inline void audit_mmap_fd(int fd, int flags)
-{ }
-static inline void audit_ptrace(struct task_struct *t)
-{ }
+#define audit_alloc(t) ({ 0; })
+#define audit_free(t) do { ; } while (0)
+#define audit_syscall_entry(ta,a,b,c,d,e) do { ; } while (0)
+#define audit_syscall_exit(r) do { ; } while (0)
+#define audit_dummy_context() 1
+#define audit_getname(n) do { ; } while (0)
+#define audit_putname(n) do { ; } while (0)
+#define __audit_inode(n,d) do { ; } while (0)
+#define __audit_inode_child(i,p) do { ; } while (0)
+#define audit_inode(n,d) do { (void)(d); } while (0)
+#define audit_inode_child(i,p) do { ; } while (0)
+#define audit_core_dumps(i) do { ; } while (0)
+#define audit_seccomp(i,s,c) do { ; } while (0)
+#define auditsc_get_stamp(c,t,s) (0)
+#define audit_get_loginuid(t) (INVALID_UID)
+#define audit_get_sessionid(t) (-1)
+#define audit_log_task_context(b) do { ; } while (0)
+#define audit_log_task_info(b, t) do { ; } while (0)
+#define audit_ipc_obj(i) ((void)0)
+#define audit_ipc_set_perm(q,u,g,m) ((void)0)
+#define audit_bprm(p) ({ 0; })
+#define audit_socketcall(n,a) ((void)0)
+#define audit_fd_pair(n,a) ((void)0)
+#define audit_sockaddr(len, addr) ({ 0; })
+#define audit_mq_open(o,m,a) ((void)0)
+#define audit_mq_sendrecv(d,l,p,t) ((void)0)
+#define audit_mq_notify(d,n) ((void)0)
+#define audit_mq_getsetattr(d,s) ((void)0)
+#define audit_log_bprm_fcaps(b, ncr, ocr) ({ 0; })
+#define audit_log_capset(pid, ncr, ocr) ((void)0)
+#define audit_mmap_fd(fd, flags) ((void)0)
+#define audit_ptrace(t) ((void)0)
 #define audit_n_rules 0
 #define audit_signals 0
 #endif /* CONFIG_AUDITSYSCALL */
@@ -741,6 +682,7 @@ extern void		    audit_log_n_hex(struct audit_buffer *a=
b,
 extern void		    audit_log_n_string(struct audit_buffer *ab,
 					       const char *buf,
 					       size_t n);
+#define audit_log_string(a,b) audit_log_n_string(a, b, strlen(b));
 extern void		    audit_log_n_untrustedstring(struct audit_buffer *ab,
 							const char *string,
 							size_t n);
@@ -757,8 +699,7 @@ extern void		    audit_log_lost(const char *message);
 #ifdef CONFIG_SECURITY
 extern void 		    audit_log_secctx(struct audit_buffer *ab, u32 secid);
 #else
-static inline void	    audit_log_secctx(struct audit_buffer *ab, u32 secid)
-{ }
+#define audit_log_secctx(b,s) do { ; } while (0)
 #endif
=20
 extern int		    audit_update_lsm_rules(void);
@@ -770,50 +711,22 @@ extern int  audit_receive_filter(int type, int pid, i=
nt seq,
 				void *data, size_t datasz, kuid_t loginuid,
 				u32 sessionid, u32 sid);
 extern int audit_enabled;
-#else /* CONFIG_AUDIT */
-static inline __printf(4, 5)
-void audit_log(struct audit_context *ctx, gfp_t gfp_mask, int type,
-	       const char *fmt, ...)
-{ }
-static inline struct audit_buffer *audit_log_start(struct audit_context *c=
tx,
-						   gfp_t gfp_mask, int type)
-{
-	return NULL;
-}
-static inline __printf(2, 3)
-void audit_log_format(struct audit_buffer *ab, const char *fmt, ...)
-{ }
-static inline void audit_log_end(struct audit_buffer *ab)
-{ }
-static inline void audit_log_n_hex(struct audit_buffer *ab,
-				   const unsigned char *buf, size_t len)
-{ }
-static inline void audit_log_n_string(struct audit_buffer *ab,
-				      const char *buf, size_t n)
-{ }
-static inline void  audit_log_n_untrustedstring(struct audit_buffer *ab,
-						const char *string, size_t n)
-{ }
-static inline void audit_log_untrustedstring(struct audit_buffer *ab,
-					     const char *string)
-{ }
-static inline void audit_log_d_path(struct audit_buffer *ab,
-				    const char *prefix,
-				    const struct path *path)
-{ }
-static inline void audit_log_key(struct audit_buffer *ab, char *key)
-{ }
-static inline void audit_log_link_denied(const char *string,
-					 const struct path *link)
-{ }
-static inline void audit_log_secctx(struct audit_buffer *ab, u32 secid)
-{ }
+#else
+#define audit_log(c,g,t,f,...) do { ; } while (0)
+#define audit_log_start(c,g,t) ({ NULL; })
+#define audit_log_vformat(b,f,a) do { ; } while (0)
+#define audit_log_format(b,f,...) do { ; } while (0)
+#define audit_log_end(b) do { ; } while (0)
+#define audit_log_n_hex(a,b,l) do { ; } while (0)
+#define audit_log_n_string(a,c,l) do { ; } while (0)
+#define audit_log_string(a,c) do { ; } while (0)
+#define audit_log_n_untrustedstring(a,n,s) do { ; } while (0)
+#define audit_log_untrustedstring(a,s) do { ; } while (0)
+#define audit_log_d_path(b, p, d) do { ; } while (0)
+#define audit_log_key(b, k) do { ; } while (0)
+#define audit_log_link_denied(o, l) do { ; } while (0)
+#define audit_log_secctx(b,s) do { ; } while (0)
 #define audit_enabled 0
-#endif /* CONFIG_AUDIT */
-static inline void audit_log_string(struct audit_buffer *ab, const char *b=
uf)
-{
-	audit_log_n_string(ab, buf, strlen(buf));
-}
-
+#endif
 #endif
 #endif
diff --git a/include/linux/pageblock-flags.h b/include/linux/pageblock-flag=
s.h
index eed27f4..9ed5841 100644
--- a/include/linux/pageblock-flags.h
+++ b/include/linux/pageblock-flags.h
@@ -30,7 +30,7 @@ enum pageblock_bits {
 	PB_migrate,
 	PB_migrate_end =3D PB_migrate + 3 - 1,
 			/* 3 bits required for migrate types */
-#ifdef CONFIG_COMPACTION
+#if defined(CONFIG_COMPACTION) || defined(CONFIG_CMA)
 	PB_migrate_skip,/* If set the block is skipped by compaction */
 #endif /* CONFIG_COMPACTION */
 	NR_PAGEBLOCK_BITS
@@ -68,7 +68,7 @@ unsigned long get_pageblock_flags_group(struct page *page,
 void set_pageblock_flags_group(struct page *page, unsigned long flags,
 					int start_bitidx, int end_bitidx);
=20
-#ifdef CONFIG_COMPACTION
+#if defined(CONFIG_COMPACTION) || defined(CONFIG_CMA)
 #define get_pageblock_skip(page) \
 			get_pageblock_flags_group(page, PB_migrate_skip,     \
 							PB_migrate_skip + 1)
diff --git a/mm/compaction.c b/mm/compaction.c
index 2769d96..3382869 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -238,6 +238,7 @@ static unsigned long isolate_freepages_block(struct com=
pact_control *cc,
 				struct list_head *freelist,
 				bool strict)
 {
+	unsigned long nr_strict_required =3D end_pfn - blockpfn;
 	int nr_scanned =3D 0, total_isolated =3D 0;
 	struct page *cursor, *valid_page =3D NULL;
 	unsigned long flags;
@@ -300,10 +301,10 @@ static unsigned long isolate_freepages_block(struct c=
ompact_control *cc,
=20
 	/*
 	 * If strict isolation is requested by CMA then check that all the
-	 * pages scanned were isolated. If there were any failures, 0 is
+	 * pages requested were isolated. If there were any failures, 0 is
 	 * returned and CMA will fail.
 	 */
-	if (strict && nr_scanned !=3D total_isolated)
+	if (strict && nr_strict_required !=3D total_isolated)
 		total_isolated =3D 0;
=20
 	if (locked)

--y0ulUmNC+osPPQO6--

--H1spWtNR+x+ondvy
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJQauKOAAoJEN0jrNd/PrOhQ6QP/0X8gupVaxglwg3Kz+mUIdRH
sKRAsHhixWRejgVdphrKjnjiyEIQGD511ep8KzVE1sHfbDwsMtE+i88MkBgdkuTN
Aa3ro/P6vWWCIYgwqlxPfIO383yzOJDwfGxOPHKn9mJQefYpzNFf7irbBU3lZMyc
NYQHZszB9AWcMuLSj9BcKQeySesTy7NJiFPc6JNfjMYf/DIHnjhge+TS8z5rMX0D
wy2MgE2w05rrnYgBh+qsKD7Seyjgg3uFdfBZJ/vthjG+UqJqBWuG98isu2el3YQo
rfjH8YV9AHBVFsfX1hcfmCzFgwwQEq3ZYzVNXVPwLu/EPWYjOrTVBLYib4jUq+Ii
B9AAGKMZbUpAp+9e7XbJpsSoEbbgKEeKslbqQ+zi6kC7Vy6rIG9cfK55xNIgzSfK
SXoqTiTtiyLo9bGe1N47hJrqarPs/G/DsoXhIUfD85ZCQ/S0n4tNrEVFNJht2ZQE
+MQ/uPt/alR73GnbOx3O8mntJ32eyT/szgLKP4n4GSUewRu7AQ8Up8bis/Vsl7eL
4nQr852xGS/LhkyvvGeOuX9fFutUuZVICyW6nIh/b+H/KbbySa0sbpGDbPCMvYFR
m6YhdPiOPAuiL+C0QA04msgkksG6LihGiRqPsNRj9IprJGzxxXOzAAVv7KfHQR7Q
C7LikCpTb3VrJ89YSO/9
=meCq
-----END PGP SIGNATURE-----

--H1spWtNR+x+ondvy--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
