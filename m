Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id EB78E6B000C
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 10:35:39 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id u68so1077522wmd.5
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 07:35:39 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.131])
        by mx.google.com with ESMTPS id 93si1915814wrn.101.2018.03.14.07.35.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 07:35:37 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 00/16] remove eight obsolete architectures
Date: Wed, 14 Mar 2018 15:34:59 +0100
Message-Id: <20180314143529.1456168-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-doc@vger.kernel.org, linux-block@vger.kernel.org, linux-ide@vger.kernel.org, linux-input@vger.kernel.org, netdev@vger.kernel.org, linux-wireless@vger.kernel.org, linux-pwm@vger.kernel.org, linux-rtc@vger.kernel.org, linux-spi@vger.kernel.org, linux-usb@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-fbdev@vger.kernel.org, linux-watchdog@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Here is the collection of patches I have applied to my 'asm-generic' tree
on top of the 'metag' removal. This does not include any of the device
drivers, I'll send those separately to a someone different list of people.

The removal came out of a discussion that is now documented at
https://lwn.net/Articles/748074/

Following up from the state described there, I ended up removing the
mn10300, tile, blackfin and cris architectures directly, rather than
waiting, after consulting with the respective maintainers.

However, the unicore32 architecture is no longer part of the removal,
after its maintainer Xuetao Guan said that the port is still actively
being used and that he intends to keep working on it, and that he will
try to provide updated toolchain sources.

In the end, it seems that while the eight architectures are extremely
different, they all suffered the same fate: There was one company in
charge of an SoC line, a CPU microarchitecture and a software ecosystem,
which was more costly than licensing newer off-the-shelf CPU cores from
a third party (typically ARM, MIPS, or RISC-V). It seems that all the
SoC product lines are still around, but have not used the custom CPU
architectures for several years at this point.

      Arnd

Arnd Bergmann (14):
  arch: remove frv port
  arch: remove m32r port
  arch: remove score port
  arch: remove blackfin port
  arch: remove tile port
  procfs: remove CONFIG_HARDWALL dependency
  mm: remove blackfin MPU support
  mm: remove obsolete alloc_remap()
  treewide: simplify Kconfig dependencies for removed archs
  asm-generic: siginfo: remove obsolete #ifdefs
  Documentation: arch-support: remove obsolete architectures
  asm-generic: clean up asm/unistd.h
  recordmcount.pl: drop blackin and tile support
  ktest: remove obsolete architectures

David Howells (1):
  mn10300: Remove the architecture

Jesper Nilsson (1):
  CRIS: Drop support for the CRIS port

Dirstat only (full diffstat is over 100KB):

   6.3% arch/blackfin/mach-bf548/include/mach/
   4.5% arch/blackfin/mach-bf609/include/mach/
  26.3% arch/blackfin/
   4.1% arch/cris/arch-v32/
   5.6% arch/cris/include/arch-v32/arch/hwregs/iop/
   4.1% arch/cris/include/arch-v32/mach-a3/mach/hwregs/
   4.7% arch/cris/include/arch-v32/
   7.8% arch/cris/
   5.6% arch/frv/
   5.5% arch/m32r/
   7.0% arch/mn10300/
   7.6% arch/tile/include/
   6.4% arch/tile/kernel/
   0.0% Documentation/admin-guide/
   0.0% Documentation/blackfin/
   0.0% Documentation/cris/
   0.0% Documentation/devicetree/bindings/cris/
   0.0% Documentation/devicetree/bindings/interrupt-controller/
   2.8% Documentation/features/
   0.5% Documentation/frv/
   0.0% Documentation/ioctl/
   0.0% Documentation/mn10300/
   0.0% Documentation/
   0.0% block/
   0.0% crypto/
   0.0% drivers/ide/
   0.0% drivers/input/joystick/
   0.0% drivers/isdn/hisax/
   0.0% drivers/net/ethernet/davicom/
   0.0% drivers/net/ethernet/smsc/
   0.0% drivers/net/wireless/cisco/
   0.0% drivers/pci/
   0.0% drivers/pwm/
   0.0% drivers/rtc/
   0.0% drivers/spi/
   0.0% drivers/staging/speakup/
   0.0% drivers/usb/musb/
   0.0% drivers/video/console/
   0.0% drivers/watchdog/
   0.0% fs/minix/
   0.0% fs/proc/
   0.0% fs/
   0.0% include/asm-generic/
   0.0% include/linux/
   0.0% include/uapi/asm-generic/
   0.0% init/
   0.0% kernel/
   0.0% lib/
   0.0% mm/
   0.0% samples/blackfin/
   0.0% samples/kprobes/
   0.0% samples/
   0.0% scripts/mod/
   0.0% scripts/
   0.0% tools/arch/frv/include/uapi/asm/
   0.0% tools/arch/m32r/include/uapi/asm/
   0.0% tools/arch/mn10300/include/uapi/asm/
   0.0% tools/arch/score/include/uapi/asm/
   0.0% tools/arch/tile/include/asm/
   0.0% tools/arch/tile/include/uapi/asm/
   0.0% tools/include/asm-generic/
   0.0% tools/scripts/
   0.0% tools/testing/ktest/examples/
   0.0% tools/testing/ktest/

Cc: linux-doc@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-block@vger.kernel.org
Cc: linux-ide@vger.kernel.org
Cc: linux-input@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: linux-wireless@vger.kernel.org
Cc: linux-pwm@vger.kernel.org
Cc: linux-rtc@vger.kernel.org
Cc: linux-spi@vger.kernel.org
Cc: linux-usb@vger.kernel.org
Cc: dri-devel@lists.freedesktop.org
Cc: linux-fbdev@vger.kernel.org
Cc: linux-watchdog@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-mm@kvack.org
