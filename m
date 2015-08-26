Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id AD0E76B0253
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 04:07:59 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so152842043pac.2
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 01:07:59 -0700 (PDT)
Received: from mgwkm01.jp.fujitsu.com (mgwkm01.jp.fujitsu.com. [202.219.69.168])
        by mx.google.com with ESMTPS id cq7si27439126pad.104.2015.08.26.01.07.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Aug 2015 01:07:58 -0700 (PDT)
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id 95512AC0251
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 17:07:55 +0900 (JST)
From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v2 0/3] Introduce "efi_fake_mem_mirror" boot option
Date: Thu, 27 Aug 2015 02:10:31 +0900
Message-Id: <1440609031-14695-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-efi@vger.kernel.org, x86@kernel.org, matt.fleming@intel.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com
Cc: tony.luck@intel.com, qiuxishi@huawei.com, kamezawa.hiroyu@jp.fujitsu.com, ard.biesheuvel@linaro.org, linux-mm@kvack.org, Taku Izumi <izumi.taku@jp.fujitsu.com>

UEFI spec 2.5 introduces new Memory Attribute Definition named
EFI_MEMORY_MORE_RELIABLE which indicates which memory ranges are
mirrored. Now linux kernel can recognize which memory ranges are mirrored
by handling EFI_MEMORY_MORE_RELIABLE attributes.
However testing this feature necesitates boxes with UEFI spec 2.5 complied
firmware.

This patchset introduces new boot option named "efi_fake_mem_mirror".
By specifying this parameter, you can mark specific memory as
mirrored memory. This is useful for debugging of Memory Address Range
Mirroring feature.

v1 -> v2:
 - change abbreviation of EFI_MEMORY_MORE_RELIABLE from "RELY" to "MR"
 - add patch (2/3) for changing abbreviation of EFI_MEMORY_RUNTIME
 - migrate some code from arch/x86/platform/efi/quirks to
   drivers/firmware/efi/fake_mem.c and create config EFI_FAKE_MEMMAP

Taku Izumi (3):
  efi: Add EFI_MEMORY_MORE_RELIABLE support to efi_md_typeattr_format()
  efi: Change abbreviation of EFI_MEMORY_RUNTIME from "RUN" to "RT"
  x86, efi: Add "efi_fake_mem_mirror" boot option

 Documentation/kernel-parameters.txt |   8 ++
 arch/x86/include/asm/efi.h          |   1 +
 arch/x86/kernel/setup.c             |   4 +-
 arch/x86/platform/efi/efi.c         |   2 +-
 drivers/firmware/efi/Kconfig        |  12 +++
 drivers/firmware/efi/Makefile       |   1 +
 drivers/firmware/efi/efi.c          |   8 +-
 drivers/firmware/efi/fake_mem.c     | 204 ++++++++++++++++++++++++++++++++++++
 include/linux/efi.h                 |   6 ++
 9 files changed, 241 insertions(+), 5 deletions(-)
 create mode 100644 drivers/firmware/efi/fake_mem.c

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
