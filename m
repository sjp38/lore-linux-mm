Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7C9AB6B0033
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 15:44:33 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id d8so559166pgt.1
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 12:44:33 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id p30si5649205pli.519.2017.09.14.12.44.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Sep 2017 12:44:30 -0700 (PDT)
From: "Williams, Dan J" <dan.j.williams@intel.com>
Subject: [GIT PULL] MAP_SHARED_VALIDATE for 4.14
Date: Thu, 14 Sep 2017 19:44:28 +0000
Message-ID: <1505418254.14842.7.camel@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-7"
Content-ID: <BA5B522EEFEE87479F191F8EB44B9372@intel.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hch@lst.de" <hch@lst.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "luto@kernel.org" <luto@kernel.org>, "julia.lawall@lip6.fr" <julia.lawall@lip6.fr>, "jack@suse.cz" <jack@suse.cz>

Hi Linus, please consider pulling:

  git://git.kernel.org/pub/scm/linux/kernel/git/nvdimm/nvdimm tags/map-shar=
ed-validate-for-4.14

...for 4.14 as a pre-requisite for the proposed mmap flags (MAP+AF8-SYNC
and MAP+AF8-DIRECT) being developed for 4.15 consideration. As I
highlighted in the last posting +AFs-1+AF0- these patches are based on a ra=
ndom
point in the merge window (state of the tree 2 days ago). They have not
been in -next. However, they have been exposed to the 0day kbuild robot
with all reports fixed. A test merge with the state of the tree today
finds no conflicts, nor new mmap handlers for the coccinelle script to
convert.

The only change since the last posting was clarifying in commit
4aac0d08f6d1 +ACI-mm: introduce MAP+AF8-SHARED+AF8-VALIDATE...+ACI- that
MAP+AF8-SHARED+AF8-VALIDATE is just MAP+AF8-SHARED+-validate, not a bitmap =
to be
added to new flag values, and that it is a unique MAP+AF8-TYPE number not
necessarily (MAP+AF8-SHARED+AHw-MAP+AF8-PRIVATE) (from Jan's review).

Now, we could wait until 4.15 and do the same rebase, run coccinelle
script, rinse, and repeat process for 4.15. I.e wait until we also have
the MAP+AF8-SYNC and/or MAP+AF8-DIRECT to merge at the same time, but I thi=
nk
it is preferable to base that development on early 4.14-rc and get it
some soak time in -next.

Another alternative is to just get patch1, commit 403fee48224c +ACI-vfs:
add flags...+ACI-, in for 4.14 and save MAP+AF8-SHARED+AF8-VALIDATE to arri=
ve in
the next merge window coincident with the new flags implementation.

Lastly, the alternative to all this thrash is carrying the flags in the
vma. That bloats vm+AF8-area+AF8-struct everywhere and complicates vma
splitting / merging for the handful of mmap implementations that will
ever care about the new flags.

+AFs-1+AF0-: https://lwn.net/Articles/733281/

---

The following changes since commit 8fac2f96ab86b0e14ec4e42851e21e9b518bdc55=
:

  Merge branch 'for-linus' of git://git.armlinux.org.uk/+AH4-rmk/linux-arm =
(2017-09-12 06:10:44 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/nvdimm/nvdimm tags/map-shar=
ed-validate-for-4.14

for you to fetch changes up to 4aac0d08f6d1ae4475bbfe761b943d105e11b82a:

  mm: introduce MAP+AF8-SHARED+AF8-VALIDATE, a mechanism to safely define n=
ew mmap flags (2017-09-12 10:12:34 -0700)

----------------------------------------------------------------
MAP+AF8-SHARED+AF8-VALIDATE for 4.14

Preparation infrastructure for introducing new mmap flags:

+ACo- Introduce MAP+AF8-SHARED+AF8-VALIDATE as an mmap(2) flag that in addi=
tion to
  creating a MAP+AF8-SHARED mapping also arranges for the +AEA-flags parame=
ter
  of mmap(2) to be validated by the endpoint mmap-file-operation. I.e.
  new mmap flags require per mmap implementation opt-in and run time
  validation.

+ACo- Make the +AEA-flags parameter available to all mmap implementations, =
both
  top-level 'struct file+AF8-operations' and sub-level leaf implementations=
.

----------------------------------------------------------------
Dan Williams (2):
      vfs: add flags parameter to all -+AD4-mmap() handlers
      mm: introduce MAP+AF8-SHARED+AF8-VALIDATE, a mechanism to safely defi=
ne new mmap flags

 arch/alpha/include/uapi/asm/mman.h                 +AHw-  1 +-
 arch/arc/kernel/arc+AF8-hostlink.c                     +AHw-  3 +--
 arch/mips/include/uapi/asm/mman.h                  +AHw-  1 +-
 arch/mips/kernel/vdso.c                            +AHw-  2 +--
 arch/parisc/include/uapi/asm/mman.h                +AHw-  1 +-
 arch/powerpc/kernel/proc+AF8-powerpc.c                 +AHw-  3 +--
 arch/powerpc/kvm/book3s+AF8-64+AF8-vio.c                   +AHw-  3 +--
 arch/powerpc/platforms/cell/spufs/file.c           +AHw- 21 +-+-+-+-+-+-+-=
----
 arch/powerpc/platforms/powernv/memtrace.c          +AHw-  3 +--
 arch/powerpc/platforms/powernv/opal-prd.c          +AHw-  3 +--
 arch/tile/mm/elf.c                                 +AHw-  3 +--
 arch/um/drivers/mmapper+AF8-kern.c                     +AHw-  3 +--
 arch/xtensa/include/uapi/asm/mman.h                +AHw-  1 +-
 drivers/android/binder.c                           +AHw-  3 +--
 drivers/auxdisplay/cfag12864bfb.c                  +AHw-  3 +--
 drivers/auxdisplay/ht16k33.c                       +AHw-  3 +--
 drivers/char/agp/frontend.c                        +AHw-  3 +--
 drivers/char/bsr.c                                 +AHw-  3 +--
 drivers/char/hpet.c                                +AHw-  6 +-+--
 drivers/char/mbcs.c                                +AHw-  3 +--
 drivers/char/mbcs.h                                +AHw-  3 +--
 drivers/char/mem.c                                 +AHw- 11 +-+-+-+---
 drivers/char/mspec.c                               +AHw-  9 +-+-+---
 drivers/char/uv+AF8-mmtimer.c                          +AHw-  6 +-+--
 drivers/dax/device.c                               +AHw-  3 +--
 drivers/dma-buf/dma-buf.c                          +AHw- 11 +-+-+-+---
 drivers/firewire/core-cdev.c                       +AHw-  3 +--
 drivers/gpu/drm/amd/amdgpu/amdgpu+AF8-ttm.c            +AHw-  3 +--
 drivers/gpu/drm/amd/amdgpu/amdgpu+AF8-ttm.h            +AHw-  3 +--
 drivers/gpu/drm/amd/amdkfd/kfd+AF8-chardev.c           +AHw-  5 +-+--
 drivers/gpu/drm/armada/armada+AF8-gem.c                +AHw-  3 +--
 drivers/gpu/drm/ast/ast+AF8-drv.h                      +AHw-  3 +--
 drivers/gpu/drm/ast/ast+AF8-ttm.c                      +AHw-  3 +--
 drivers/gpu/drm/bochs/bochs.h                      +AHw-  3 +--
 drivers/gpu/drm/bochs/bochs+AF8-fbdev.c                +AHw-  2 +--
 drivers/gpu/drm/bochs/bochs+AF8-mm.c                   +AHw-  3 +--
 drivers/gpu/drm/cirrus/cirrus+AF8-drv.h                +AHw-  3 +--
 drivers/gpu/drm/cirrus/cirrus+AF8-ttm.c                +AHw-  3 +--
 drivers/gpu/drm/drm+AF8-fb+AF8-cma+AF8-helper.c                +AHw-  8 +-=
+---
 drivers/gpu/drm/drm+AF8-gem.c                          +AHw-  4 +--
 drivers/gpu/drm/drm+AF8-gem+AF8-cma+AF8-helper.c               +AHw-  8 +-=
+---
 drivers/gpu/drm/drm+AF8-prime.c                        +AHw-  5 +-+--
 drivers/gpu/drm/drm+AF8-vm.c                           +AHw-  3 +--
 drivers/gpu/drm/etnaviv/etnaviv+AF8-drv.h              +AHw-  6 +-+--
 drivers/gpu/drm/etnaviv/etnaviv+AF8-gem.c              +AHw- 11 +-+-+----
 drivers/gpu/drm/etnaviv/etnaviv+AF8-gem.h              +AHw-  3 +--
 drivers/gpu/drm/etnaviv/etnaviv+AF8-gem+AF8-prime.c        +AHw-  9 +-+-+-=
--
 drivers/gpu/drm/exynos/exynos+AF8-drm+AF8-fbdev.c          +AHw-  2 +--
 drivers/gpu/drm/exynos/exynos+AF8-drm+AF8-gem.c            +AHw- 10 +-+-+-=
--
 drivers/gpu/drm/exynos/exynos+AF8-drm+AF8-gem.h            +AHw-  6 +-+--
 drivers/gpu/drm/gma500/framebuffer.c               +AHw-  3 +--
 drivers/gpu/drm/hisilicon/hibmc/hibmc+AF8-drm+AF8-drv.h    +AHw-  3 +--
 drivers/gpu/drm/hisilicon/hibmc/hibmc+AF8-ttm.c        +AHw-  3 +--
 drivers/gpu/drm/i810/i810+AF8-dma.c                    +AHw-  3 +--
 drivers/gpu/drm/i915/i915+AF8-gem+AF8-dmabuf.c             +AHw-  6 +-+--
 drivers/gpu/drm/i915/selftests/mock+AF8-dmabuf.c       +AHw-  4 +--
 drivers/gpu/drm/mediatek/mtk+AF8-drm+AF8-gem.c             +AHw-  8 +-+---
 drivers/gpu/drm/mediatek/mtk+AF8-drm+AF8-gem.h             +AHw-  5 +-+--
 drivers/gpu/drm/mgag200/mgag200+AF8-drv.h              +AHw-  3 +--
 drivers/gpu/drm/mgag200/mgag200+AF8-ttm.c              +AHw-  3 +--
 drivers/gpu/drm/msm/msm+AF8-drv.h                      +AHw-  6 +-+--
 drivers/gpu/drm/msm/msm+AF8-fbdev.c                    +AHw-  6 +-+--
 drivers/gpu/drm/msm/msm+AF8-gem.c                      +AHw-  5 +-+--
 drivers/gpu/drm/msm/msm+AF8-gem+AF8-prime.c                +AHw-  3 +--
 drivers/gpu/drm/nouveau/nouveau+AF8-ttm.c              +AHw-  5 +-+--
 drivers/gpu/drm/nouveau/nouveau+AF8-ttm.h              +AHw-  2 +--
 drivers/gpu/drm/omapdrm/omap+AF8-drv.h                 +AHw-  3 +--
 drivers/gpu/drm/omapdrm/omap+AF8-gem.c                 +AHw-  5 +-+--
 drivers/gpu/drm/omapdrm/omap+AF8-gem+AF8-dmabuf.c          +AHw-  2 +--
 drivers/gpu/drm/qxl/qxl+AF8-drv.h                      +AHw-  6 +-+--
 drivers/gpu/drm/qxl/qxl+AF8-prime.c                    +AHw-  2 +--
 drivers/gpu/drm/qxl/qxl+AF8-ttm.c                      +AHw-  3 +--
 drivers/gpu/drm/radeon/radeon+AF8-drv.c                +AHw-  3 +--
 drivers/gpu/drm/radeon/radeon+AF8-ttm.c                +AHw-  3 +--
 drivers/gpu/drm/rockchip/rockchip+AF8-drm+AF8-fbdev.c      +AHw-  5 +-+--
 drivers/gpu/drm/rockchip/rockchip+AF8-drm+AF8-gem.c        +AHw-  7 +-+---
 drivers/gpu/drm/rockchip/rockchip+AF8-drm+AF8-gem.h        +AHw-  5 +-+--
 drivers/gpu/drm/tegra/gem.c                        +AHw-  9 +-+-+---
 drivers/gpu/drm/tegra/gem.h                        +AHw-  3 +--
 drivers/gpu/drm/udl/udl+AF8-dmabuf.c                   +AHw-  3 +--
 drivers/gpu/drm/udl/udl+AF8-drv.h                      +AHw-  3 +--
 drivers/gpu/drm/udl/udl+AF8-fb.c                       +AHw-  3 +--
 drivers/gpu/drm/udl/udl+AF8-gem.c                      +AHw-  5 +-+--
 drivers/gpu/drm/vc4/vc4+AF8-bo.c                       +AHw- 10 +-+-+---
 drivers/gpu/drm/vc4/vc4+AF8-drv.h                      +AHw-  6 +-+--
 drivers/gpu/drm/vgem/vgem+AF8-drv.c                    +AHw- 10 +-+-+---
 drivers/gpu/drm/virtio/virtgpu+AF8-drv.h               +AHw-  6 +-+--
 drivers/gpu/drm/virtio/virtgpu+AF8-prime.c             +AHw-  2 +--
 drivers/gpu/drm/virtio/virtgpu+AF8-ttm.c               +AHw-  3 +--
 drivers/gpu/drm/vmwgfx/vmwgfx+AF8-drv.h                +AHw-  3 +--
 drivers/gpu/drm/vmwgfx/vmwgfx+AF8-prime.c              +AHw-  3 +--
 drivers/gpu/drm/vmwgfx/vmwgfx+AF8-ttm+AF8-glue.c           +AHw-  3 +--
 drivers/hsi/clients/cmt+AF8-speech.c                   +AHw-  3 +--
 drivers/hwtracing/intel+AF8-th/msu.c                   +AHw-  3 +--
 drivers/hwtracing/stm/core.c                       +AHw-  3 +--
 drivers/infiniband/core/uverbs+AF8-main.c              +AHw-  3 +--
 drivers/infiniband/hw/hfi1/file+AF8-ops.c              +AHw-  6 +-+--
 drivers/infiniband/hw/qib/qib+AF8-file+AF8-ops.c           +AHw-  5 +-+--
 drivers/media/common/saa7146/saa7146+AF8-fops.c        +AHw-  3 +--
 drivers/media/pci/bt8xx/bttv-driver.c              +AHw-  3 +--
 drivers/media/pci/cx18/cx18-fileops.c              +AHw-  3 +--
 drivers/media/pci/cx18/cx18-fileops.h              +AHw-  3 +--
 drivers/media/pci/meye/meye.c                      +AHw-  3 +--
 drivers/media/pci/zoran/zoran+AF8-driver.c             +AHw-  2 +--
 drivers/media/platform/davinci/vpfe+AF8-capture.c      +AHw-  3 +--
 drivers/media/platform/exynos-gsc/gsc-m2m.c        +AHw-  3 +--
 drivers/media/platform/fsl-viu.c                   +AHw-  3 +--
 drivers/media/platform/m2m-deinterlace.c           +AHw-  3 +--
 drivers/media/platform/mx2+AF8-emmaprp.c               +AHw-  3 +--
 drivers/media/platform/omap/omap+AF8-vout.c            +AHw-  3 +--
 drivers/media/platform/omap3isp/ispvideo.c         +AHw-  3 +--
 drivers/media/platform/s3c-camif/camif-capture.c   +AHw-  3 +--
 drivers/media/platform/s5p-mfc/s5p+AF8-mfc.c           +AHw-  3 +--
 drivers/media/platform/sh+AF8-veu.c                    +AHw-  3 +--
 drivers/media/platform/soc+AF8-camera/soc+AF8-camera.c     +AHw-  3 +--
 drivers/media/platform/via-camera.c                +AHw-  3 +--
 drivers/media/usb/cpia2/cpia2+AF8-v4l.c                +AHw-  3 +--
 drivers/media/usb/cx231xx/cx231xx-417.c            +AHw-  3 +--
 drivers/media/usb/cx231xx/cx231xx-video.c          +AHw-  3 +--
 drivers/media/usb/gspca/gspca.c                    +AHw-  3 +--
 drivers/media/usb/stkwebcam/stk-webcam.c           +AHw-  3 +--
 drivers/media/usb/tm6000/tm6000-video.c            +AHw-  3 +--
 drivers/media/usb/usbvision/usbvision-video.c      +AHw-  3 +--
 drivers/media/usb/uvc/uvc+AF8-v4l2.c                   +AHw-  3 +--
 drivers/media/usb/zr364xx/zr364xx.c                +AHw-  3 +--
 drivers/media/v4l2-core/v4l2-dev.c                 +AHw-  5 +-+--
 drivers/media/v4l2-core/v4l2-mem2mem.c             +AHw-  3 +--
 drivers/media/v4l2-core/videobuf2-dma-contig.c     +AHw-  2 +--
 drivers/media/v4l2-core/videobuf2-dma-sg.c         +AHw-  2 +--
 drivers/media/v4l2-core/videobuf2-v4l2.c           +AHw-  3 +--
 drivers/media/v4l2-core/videobuf2-vmalloc.c        +AHw-  2 +--
 drivers/misc/aspeed-lpc-ctrl.c                     +AHw-  3 +--
 drivers/misc/cxl/api.c                             +AHw-  5 +-+--
 drivers/misc/cxl/cxl.h                             +AHw-  3 +--
 drivers/misc/cxl/file.c                            +AHw-  3 +--
 drivers/misc/genwqe/card+AF8-dev.c                     +AHw-  3 +--
 drivers/misc/mic/scif/scif+AF8-fd.c                    +AHw-  3 +--
 drivers/misc/mic/vop/vop+AF8-vringh.c                  +AHw-  3 +--
 drivers/misc/sgi-gru/grufile.c                     +AHw-  3 +--
 drivers/mtd/mtdchar.c                              +AHw-  3 +--
 drivers/pci/proc.c                                 +AHw-  3 +--
 drivers/rapidio/devices/rio+AF8-mport+AF8-cdev.c           +AHw-  3 +--
 drivers/sbus/char/flash.c                          +AHw-  3 +--
 drivers/sbus/char/jsflash.c                        +AHw-  3 +--
 drivers/scsi/cxlflash/superpipe.c                  +AHw-  5 +-+--
 drivers/scsi/sg.c                                  +AHw-  3 +--
 drivers/staging/android/ashmem.c                   +AHw-  3 +--
 drivers/staging/android/ion/ion.c                  +AHw-  3 +--
 drivers/staging/comedi/comedi+AF8-fops.c               +AHw-  3 +--
 .../staging/lustre/lustre/llite/llite+AF8-internal.h   +AHw-  3 +--
 drivers/staging/lustre/lustre/llite/llite+AF8-mmap.c   +AHw-  5 +-+--
 .../media/atomisp/pci/atomisp2/atomisp+AF8-fops.c      +AHw-  6 +-+--
 drivers/staging/media/davinci+AF8-vpfe/vpfe+AF8-video.c    +AHw-  3 +--
 drivers/staging/media/omap4iss/iss+AF8-video.c         +AHw-  3 +--
 drivers/staging/vboxvideo/vbox+AF8-drv.h               +AHw-  5 +-+--
 drivers/staging/vboxvideo/vbox+AF8-prime.c             +AHw-  3 +--
 drivers/staging/vboxvideo/vbox+AF8-ttm.c               +AHw-  3 +--
 drivers/staging/vme/devices/vme+AF8-user.c             +AHw-  3 +--
 drivers/tee/tee+AF8-shm.c                              +AHw-  3 +--
 drivers/uio/uio.c                                  +AHw-  3 +--
 drivers/usb/core/devio.c                           +AHw-  3 +--
 drivers/usb/gadget/function/uvc+AF8-v4l2.c             +AHw-  3 +--
 drivers/usb/mon/mon+AF8-bin.c                          +AHw-  3 +--
 drivers/vfio/vfio.c                                +AHw-  7 +-+-+--
 drivers/video/fbdev/68328fb.c                      +AHw-  6 +-+--
 drivers/video/fbdev/amba-clcd.c                    +AHw-  2 +--
 drivers/video/fbdev/aty/atyfb+AF8-base.c               +AHw-  6 +-+--
 drivers/video/fbdev/au1100fb.c                     +AHw-  3 +--
 drivers/video/fbdev/au1200fb.c                     +AHw-  3 +--
 drivers/video/fbdev/bw2.c                          +AHw-  5 +-+--
 drivers/video/fbdev/cg14.c                         +AHw-  5 +-+--
 drivers/video/fbdev/cg3.c                          +AHw-  5 +-+--
 drivers/video/fbdev/cg6.c                          +AHw-  5 +-+--
 drivers/video/fbdev/controlfb.c                    +AHw-  4 +--
 drivers/video/fbdev/core/fb+AF8-defio.c                +AHw-  3 +--
 drivers/video/fbdev/core/fbmem.c                   +AHw-  5 +-+--
 drivers/video/fbdev/ep93xx-fb.c                    +AHw-  3 +--
 drivers/video/fbdev/fb-puv3.c                      +AHw-  2 +--
 drivers/video/fbdev/ffb.c                          +AHw-  5 +-+--
 drivers/video/fbdev/gbefb.c                        +AHw-  2 +--
 drivers/video/fbdev/igafb.c                        +AHw-  2 +--
 drivers/video/fbdev/leo.c                          +AHw-  5 +-+--
 drivers/video/fbdev/omap/omapfb+AF8-main.c             +AHw-  3 +--
 drivers/video/fbdev/omap2/omapfb/omapfb-main.c     +AHw-  3 +--
 drivers/video/fbdev/p9100.c                        +AHw-  6 +-+--
 drivers/video/fbdev/ps3fb.c                        +AHw-  3 +--
 drivers/video/fbdev/pxa3xx-gcu.c                   +AHw-  3 +--
 drivers/video/fbdev/sa1100fb.c                     +AHw-  2 +--
 drivers/video/fbdev/sh+AF8-mobile+AF8-lcdcfb.c             +AHw-  6 +-+--
 drivers/video/fbdev/smscufx.c                      +AHw-  3 +--
 drivers/video/fbdev/tcx.c                          +AHw-  5 +-+--
 drivers/video/fbdev/udlfb.c                        +AHw-  3 +--
 drivers/video/fbdev/vermilion/vermilion.c          +AHw-  3 +--
 drivers/video/fbdev/vfb.c                          +AHw-  4 +--
 drivers/xen/gntalloc.c                             +AHw-  3 +--
 drivers/xen/gntdev.c                               +AHw-  3 +--
 drivers/xen/privcmd.c                              +AHw-  3 +--
 drivers/xen/xenbus/xenbus+AF8-dev+AF8-backend.c            +AHw-  3 +--
 drivers/xen/xenfs/xenstored.c                      +AHw-  3 +--
 fs/9p/vfs+AF8-file.c                                   +AHw- 10 +-+-+---
 fs/aio.c                                           +AHw-  3 +--
 fs/btrfs/file.c                                    +AHw-  4 +--
 fs/ceph/addr.c                                     +AHw-  3 +--
 fs/ceph/super.h                                    +AHw-  3 +--
 fs/cifs/cifsfs.h                                   +AHw-  6 +-+--
 fs/cifs/file.c                                     +AHw- 10 +-+-+---
 fs/coda/file.c                                     +AHw-  5 +-+--
 fs/ecryptfs/file.c                                 +AHw-  5 +-+--
 fs/ext2/file.c                                     +AHw-  5 +-+--
 fs/ext4/file.c                                     +AHw-  3 +--
 fs/f2fs/file.c                                     +AHw-  3 +--
 fs/fuse/file.c                                     +AHw-  8 +-+---
 fs/gfs2/file.c                                     +AHw-  3 +--
 fs/hugetlbfs/inode.c                               +AHw-  3 +--
 fs/kernfs/file.c                                   +AHw-  3 +--
 fs/ncpfs/mmap.c                                    +AHw-  3 +--
 fs/ncpfs/ncp+AF8-fs.h                                  +AHw-  2 +--
 fs/nfs/file.c                                      +AHw-  5 +-+--
 fs/nfs/internal.h                                  +AHw-  2 +--
 fs/nilfs2/file.c                                   +AHw-  3 +--
 fs/ocfs2/mmap.c                                    +AHw-  3 +--
 fs/ocfs2/mmap.h                                    +AHw-  3 +--
 fs/orangefs/file.c                                 +AHw-  5 +-+--
 fs/proc/inode.c                                    +AHw-  7 +-+---
 fs/proc/vmcore.c                                   +AHw-  6 +-+--
 fs/ramfs/file-nommu.c                              +AHw-  6 +-+--
 fs/romfs/mmap-nommu.c                              +AHw-  3 +--
 fs/ubifs/file.c                                    +AHw-  5 +-+--
 fs/xfs/xfs+AF8-file.c                                  +AHw-  2 +--
 include/drm/drm+AF8-drv.h                              +AHw-  3 +--
 include/drm/drm+AF8-gem.h                              +AHw-  3 +--
 include/drm/drm+AF8-gem+AF8-cma+AF8-helper.h                   +AHw-  6 +-=
+--
 include/drm/drm+AF8-legacy.h                           +AHw-  3 +--
 include/linux/dma-buf.h                            +AHw-  5 +-+--
 include/linux/fb.h                                 +AHw-  6 +-+--
 include/linux/fs.h                                 +AHw- 14 +-+-+-+----
 include/linux/mm.h                                 +AHw-  2 +--
 include/linux/mman.h                               +AHw- 44 +-+-+-+-+-+-+-=
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
 include/media/v4l2-dev.h                           +AHw-  2 +--
 include/media/v4l2-mem2mem.h                       +AHw-  3 +--
 include/media/videobuf2-v4l2.h                     +AHw-  3 +--
 include/misc/cxl.h                                 +AHw-  3 +--
 include/uapi/asm-generic/mman-common.h             +AHw-  1 +-
 ipc/shm.c                                          +AHw-  5 +-+--
 kernel/events/core.c                               +AHw-  3 +--
 kernel/kcov.c                                      +AHw-  3 +--
 kernel/relay.c                                     +AHw-  4 +--
 mm/filemap.c                                       +AHw- 15 +-+-+-+-+----
 mm/mmap.c                                          +AHw- 14 +-+-+-+-+---
 mm/nommu.c                                         +AHw-  4 +--
 mm/shmem.c                                         +AHw-  3 +--
 net/socket.c                                       +AHw-  6 +-+--
 security/selinux/selinuxfs.c                       +AHw-  6 +-+--
 sound/core/compress+AF8-offload.c                      +AHw-  3 +--
 sound/core/hwdep.c                                 +AHw-  3 +--
 sound/core/info.c                                  +AHw-  3 +--
 sound/core/init.c                                  +AHw-  3 +--
 sound/core/oss/pcm+AF8-oss.c                           +AHw-  3 +--
 sound/core/pcm+AF8-native.c                            +AHw-  3 +--
 sound/oss/soundcard.c                              +AHw-  3 +--
 sound/oss/swarm+AF8-cs4297a.c                          +AHw-  3 +--
 tools/include/uapi/asm-generic/mman-common.h       +AHw-  1 +-
 virt/kvm/kvm+AF8-main.c                                +AHw-  3 +--
 263 files changed, 722 insertions(+-), 374 deletions(-)

commit 403fee48224c8fd236a9ec23461e2d752c79101f
Author: Dan Williams +ADw-dan.j.williams+AEA-intel.com+AD4-
Date:   Tue Sep 5 17:28:59 2017 -0700

    vfs: add flags parameter to all -+AD4-mmap() handlers
   =20
    We are running running short of vma-+AD4-vm+AF8-flags. We can avoid nee=
ding a
    new VM+AF8AKg- flag in some cases if the original +AEA-flags submitted =
to mmap(2)
    is made available to the -+AD4-mmap() 'struct file+AF8-operations'
    implementation. For example, the proposed addition of MAP+AF8-DIRECT ca=
n be
    implemented without taking up a new vm+AF8-flags bit. Another motivatio=
n to
    avoid vm+AF8-flags is that they appear in /proc/+ACQ-pid/smaps, and we =
have seen
    software that tries to dangerously (TOCTOU) read smaps to infer the
    behavior of a virtual address range. Lastly, we may want to reject mmap
    attempts on a per-mmap-call basis.
   =20
    This conversion was performed by the following semantic patch. There
    were a few manual edits for oddities like proc+AF8-reg+AF8-mmap, call+A=
F8-mmap,
    drm+AF8-gem+AF8-cma+AF8-mmap, and cxl+AF8-fd+AF8-mmap.
   =20
    Thanks to Julia for helping me with coccinelle iteration to cover cases
    where the mmap routine is defined in a separate file from the operation=
s
    instance that consumes it.
   =20
    // Usage:
    // spatch mmap.cocci --no-includes --include-headers --in-place ./ -j 4=
0 --very-quiet
   =20
    virtual after+AF8-start
   =20
    +AEA-initialize:ocaml+AEA-
    +AEAAQA-
   =20
    let tbl +AD0- Hashtbl.create(100)
   =20
    let add+AF8-if+AF8-not+AF8-present fn +AD0-
      if not(Hashtbl.mem tbl fn) then Hashtbl.add tbl fn ()
   =20
    +AEA- a +AEA-
    identifier fn+ADs-
    identifier ops+ADs-
    expression E1+ADs-
    +AEAAQA-
   =20
    (
    struct file+AF8-operations ops +AD0- +AHs- ..., .mmap +AD0- fn, ...+AH0=
AOw-
    +AHw-
    struct file+AF8-operations ops+AFs-E1+AF0- +AD0- +AHs- ..., +AHs- ..., =
.mmap +AD0- fn, ...+AH0-, ...+AH0AOw-
    +AHw-
    struct etnaviv+AF8-gem+AF8-ops ops +AD0- +AHs- ..., .mmap +AD0- fn, ...=
+AH0AOw-
    +AHw-
    struct dma+AF8-buf+AF8-ops ops +AD0- +AHs- ..., .mmap +AD0- fn, ...+AH0=
AOw-
    +AHw-
    struct drm+AF8-driver ops +AD0- +AHs- ..., .gem+AF8-prime+AF8-mmap +AD0=
- fn, ...+AH0AOw-
    +AHw-
    struct fb+AF8-ops ops +AD0- +AHs- ..., .fb+AF8-mmap +AD0- fn, ...+AH0AO=
w-
    +AHw-
    struct v4l2+AF8-file+AF8-operations ops +AD0- +AHs- ..., .mmap +AD0- fn=
, ...+AH0AOw-
    )
   =20
    +AEA-script:ocaml+AEA-
    fn +ADwAPA- a.fn+ADs-
    +AEAAQA-
   =20
    add+AF8-if+AF8-not+AF8-present fn
   =20
    +AEA-finalize:ocaml depends on +ACE-after+AF8-start+AEA-
    tbls +ADwAPA- merge.tbl+ADs-
    +AEAAQA-
   =20
    List.iter (fun t -+AD4- Hashtbl.iter (fun f +AF8- -+AD4- add+AF8-if+AF8=
-not+AF8-present f) t) tbls+ADs-
    Hashtbl.iter
        (fun f +AF8- -+AD4-
          let it +AD0- new iteration() in
          it+ACM-add+AF8-virtual+AF8-rule After+AF8-start+ADs-
          it+ACM-add+AF8-virtual+AF8-identifier Fn f+ADs-
          it+ACM-register())
        tbl
   =20
    +AEA-depends on after+AF8-start+AEA-
    identifier virtual.fn+ADs-
    identifier x, y+ADs-
    type T+ADs-
    +AEAAQA-
   =20
    int fn(T +ACo-x,
            struct vm+AF8-area+AF8-struct +ACo-y
    -       )
    +-       , unsigned long map+AF8-flags)
    +AHs-
    ...
    +AH0-
   =20
    +AEA-depends on after+AF8-start+AEA-
    identifier virtual.fn+ADs-
    identifier x, y+ADs-
    type T+ADs-
    +AEAAQA-
   =20
    int fn(T +ACo-x,
            struct vm+AF8-area+AF8-struct +ACo-y
    -       )+ADs-
    +-       , unsigned long map+AF8-flags)+ADs-
   =20
    +AEA-depends on after+AF8-start+AEA-
    identifier virtual.fn+ADs-
    type T+ADs-
   =20
    +AEAAQA-
   =20
    int fn(T +ACo-,
            struct vm+AF8-area+AF8-struct +ACo-
    -       )+ADs-
    +-       , unsigned long)+ADs-
   =20
    +AEA-depends on after+AF8-start+AEA-
    identifier virtual.fn+ADs-
    expression E1, E2, E3+ADs-
    +AEAAQA-
   =20
    E3 +AD0- fn(E1, E2
    - )+ADs-
    +- , map+AF8-flags)+ADs-
   =20
    +AEA-depends on after+AF8-start+AEA-
    identifier virtual.fn+ADs-
    expression E1, E2+ADs-
    +AEAAQA-
   =20
    return fn(E1, E2
    - )+ADs-
    +- , map+AF8-flags)+ADs-
   =20
    Cc: Takashi Iwai +ADw-tiwai+AEA-suse.com+AD4-
    Cc: Christoph Hellwig +ADw-hch+AEA-lst.de+AD4-
    Cc: David Airlie +ADw-airlied+AEA-linux.ie+AD4-
    Cc: +ADw-dri-devel+AEA-lists.freedesktop.org+AD4-
    Cc: Daniel Vetter +ADw-daniel.vetter+AEA-intel.com+AD4-
    Cc: Andrew Morton +ADw-akpm+AEA-linux-foundation.org+AD4-
    Cc: Linus Torvalds +ADw-torvalds+AEA-linux-foundation.org+AD4-
    Cc: Mauro Carvalho Chehab +ADw-mchehab+AEA-s-opensource.com+AD4-
    Cc: +ADw-linux-media+AEA-vger.kernel.org+AD4-
    Cc: Greg Kroah-Hartman +ADw-gregkh+AEA-linuxfoundation.org+AD4-
    Suggested-by: Jan Kara +ADw-jack+AEA-suse.cz+AD4-
    Acked-by: Jan Kara +ADw-jack+AEA-suse.cz+AD4-
    Signed-off-by: Julia Lawall +ADw-julia.lawall+AEA-lip6.fr+AD4-
    Signed-off-by: Dan Williams +ADw-dan.j.williams+AEA-intel.com+AD4-

commit 4aac0d08f6d1ae4475bbfe761b943d105e11b82a
Author: Dan Williams +ADw-dan.j.williams+AEA-intel.com+AD4-
Date:   Mon Aug 14 14:59:39 2017 -0700

    mm: introduce MAP+AF8-SHARED+AF8-VALIDATE, a mechanism to safely define=
 new mmap flags
   =20
    The mmap(2) syscall suffers from the ABI anti-pattern of not validating
    unknown flags. However, proposals like MAP+AF8-SYNC and MAP+AF8-DIRECT =
need a
    mechanism to define new behavior that is known to fail on older kernels
    without the support. Define a new MAP+AF8-SHARED+AF8-VALIDATE flag patt=
ern that
    is guaranteed to fail on all legacy mmap implementations.
   =20
    It is worth noting that the original proposal was for a standalone
    MAP+AF8-VALIDATE flag. However, when that  could not be supported by al=
l
    archs Linus observed:
   =20
        I see why you +ACo-think+ACo- you want a bitmap. You think you want
        a bitmap because you want to make MAP+AF8-VALIDATE be part of MAP+A=
F8-SYNC
        etc, so that people can do
   =20
        ret +AD0- mmap(NULL, size, PROT+AF8-READ +AHw- PROT+AF8-WRITE, MAP+=
AF8-SHARED
                        +AHw- MAP+AF8-SYNC, fd, 0)+ADs-
   =20
        and +ACI-know+ACI- that MAP+AF8-SYNC actually takes.
   =20
        And I'm saying that whole wish is bogus. You're fundamentally
        depending on special semantics, just make it explicit. It's already
        not portable, so don't try to make it so.
   =20
        Rename that MAP+AF8-VALIDATE as MAP+AF8-SHARED+AF8-VALIDATE, make i=
t have a value
        of 0x3, and make people do
   =20
        ret +AD0- mmap(NULL, size, PROT+AF8-READ +AHw- PROT+AF8-WRITE, MAP+=
AF8-SHARED+AF8-VALIDATE
                        +AHw- MAP+AF8-SYNC, fd, 0)+ADs-
   =20
        and then the kernel side is easier too (none of that random garbage
        playing games with looking at the +ACI-MAP+AF8-VALIDATE bit+ACI-, b=
ut just another
        case statement in that map type thing.
   =20
        Boom. Done.
   =20
    Similar to -+AD4-fallocate() we also want the ability to validate the
    support for new flags on a per -+AD4-mmap() 'struct file+AF8-operations=
'
    instance basis.  Towards that end arrange for flags to be generically
    validated against a mmap+AF8-supported+AF8-mask exported by 'struct
    file+AF8-operations'. By default all existing flags are implicitly
    supported, but new flags require MAP+AF8-SHARED+AF8-VALIDATE and
    per-instance-opt-in.
   =20
    Cc: Jan Kara +ADw-jack+AEA-suse.cz+AD4-
    Cc: Arnd Bergmann +ADw-arnd+AEA-arndb.de+AD4-
    Cc: Andy Lutomirski +ADw-luto+AEA-kernel.org+AD4-
    Cc: Andrew Morton +ADw-akpm+AEA-linux-foundation.org+AD4-
    Suggested-by: Christoph Hellwig +ADw-hch+AEA-lst.de+AD4-
    Suggested-by: Linus Torvalds +ADw-torvalds+AEA-linux-foundation.org+AD4=
-
    Signed-off-by: Dan Williams +ADw-dan.j.williams+AEA-intel.com+AD4-=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
