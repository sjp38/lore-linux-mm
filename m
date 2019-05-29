Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 098FAC28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 23:24:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4A0B24329
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 23:24:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="V2B9Vgs8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4A0B24329
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 32E596B0270; Wed, 29 May 2019 19:24:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DECF6B0271; Wed, 29 May 2019 19:24:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A8BD6B0272; Wed, 29 May 2019 19:24:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id D67B76B0270
	for <linux-mm@kvack.org>; Wed, 29 May 2019 19:24:09 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d7so993404pgc.8
        for <linux-mm@kvack.org>; Wed, 29 May 2019 16:24:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding:sender;
        bh=StJ6LM8sQHkYI5UThzShneAjra5wi5bo/RYRsdxPQsA=;
        b=eN0yXMBNaaYEAd3/ezBbkED8JrWZTvAxI3B7e6CdtDOpIQu7RwU+jvyUcp/Dg6Ccgz
         C8ZhZY3eWObLZIiechYRZ6/aTC8OU0BluUIiE4DC8m8KUK4ULl04DFI+CevXhz1cdoSD
         +2nfJObwHwnRW7iufRkM190u/5TO6oH8Qenhi08Oz1cVIWnE6ONz/dHVbxz/1KqRENLJ
         cmk0SMZDbV2a9M5trGUpeHGxukdDUjcho5hHCtJ+J/0MHswvs3ymQxl7+ziOA9/OS9yw
         y9YFZXyPBVfjBiRNy6krfqq8tDTJhjUnJmjxo3dXZuXLvrLGO2xZenBLrPACy/8xRFw1
         u+WQ==
X-Gm-Message-State: APjAAAX/JVjnbiYb2Nf0pSSszv/PI0cm+CgtAWoDkcjsg5j6PZ5fkI+A
	WbG3bocrLjYGEyzyP6ongubXLPQC1GkmvKs+enTh+Z1PbxeW2+FH+hUrvLMz1SP2W2rn3w001HW
	bLZQZ0keBhHFtaUe/O54W54p2WqEso5DEyB03++2rWAsFWlas4EGFvUmTuGapiFQ=
X-Received: by 2002:a63:cd4c:: with SMTP id a12mr667451pgj.362.1559172249381;
        Wed, 29 May 2019 16:24:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw8FhUTSh8Cz77PkEdD4z4mG5lj5RRCZCgLA/avXD3kd1y++Nh9vMNeXt3UNc/9YcOL8TNA
X-Received: by 2002:a63:cd4c:: with SMTP id a12mr667378pgj.362.1559172248275;
        Wed, 29 May 2019 16:24:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559172248; cv=none;
        d=google.com; s=arc-20160816;
        b=Kd1V3gPyc/qlhOX3MOeYfC3nE59mUX11/oNhdWwuS5xaGx+R0cOyzGm0BuxF/V6tBq
         S8/mRyVL9EJ82Zx6cANgr7wuUs86Z6CXHoLwEcuxtHcIKxdIkqU7tI+3g77VIGSTeaxt
         XX25kBVCSsV78aMlyNwVTj8U/CueE8YwByT0mu4xhakATkUfHmJjL1ssTb55M7RcDIrI
         aF0w/kS1+qF6jDcrwgLmpAlg44BO5jiCVSmbmB7/gNMSXU5KAsv1CUGSjOs/zcTiEgjP
         TkzBSAXAS1V+CZHnoYFPqmmRuj6N+w1bnOf+rKQ4bZ9U9EMhylijC4weZTc8IvHUPLmf
         CnlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:content-transfer-encoding:mime-version:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=StJ6LM8sQHkYI5UThzShneAjra5wi5bo/RYRsdxPQsA=;
        b=DdziDuF50fJ4zArxOEuwihLMoGVx6ZAbDga/6z1PnAIMFu+2+ycEOO4WxOzWQFKrDM
         xtS52CTWNteDZo2/HvM95pbjv2rRQRvZHT6jVYeC86LS2z3HSl6Za3zTC5T8jdvr/G0e
         AcWJgkCHyxETvThtr08xJmRJ+dwhMfoF0hoM+bTfReAbNaHCd1fAsRJRCNsZFeEMawjo
         Hw+3pr/UHG9qwr6RtZcO3qBCwQGcxXTaOATYSBcjGl6jrfKAJjxV6gtauRvyphhUBoAD
         yDWqZIqxxKX3Wzl7/c92QBtcAvwH1ChZQCBhu0fstzFgvXEaHeWlZ4q04AfGl0xX8TyK
         aeJA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=V2B9Vgs8;
       spf=pass (google.com: best guess record for domain of mchehab@bombadil.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=mchehab@bombadil.infradead.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 32si1283172pld.6.2019.05.29.16.24.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 29 May 2019 16:24:08 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of mchehab@bombadil.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=V2B9Vgs8;
       spf=pass (google.com: best guess record for domain of mchehab@bombadil.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=mchehab@bombadil.infradead.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Sender:Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=StJ6LM8sQHkYI5UThzShneAjra5wi5bo/RYRsdxPQsA=; b=V2B9Vgs83dRLjIuQnd2C2vgYZ
	+JgyOXeO1GKHOK9c4tRnNUqThik6tzysID2WPnKRr+36Nqy1H2ECRX9ShWnHkjcDarRRE36sMjLp8
	rMBiNxdP14bOP1wi/jaweQN4P3parh4up8rfOPsYIJGMzClSMcNhqm2YUZ7FfQaCciCjPJlpLJJ9c
	aeXT61eHnnOWKaxRn+HXRc3LwC2Y8Shpt7KozKcXuJxu6PITTqtbQgKa7rv4JBRtqJqIYr0SPtFcn
	/5RDAzsKEfsB7oXgNPBlX7TDbPq/0Xg+hPhZkg4J+5oeanlc8QNxz2G9sF0j0yZAp7oTlogcPh66P
	SAaTMxt+g==;
Received: from 177.132.232.81.dynamic.adsl.gvt.net.br ([177.132.232.81] helo=bombadil.infradead.org)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hW7vL-0005Rx-II; Wed, 29 May 2019 23:23:59 +0000
Received: from mchehab by bombadil.infradead.org with local (Exim 4.92)
	(envelope-from <mchehab@bombadil.infradead.org>)
	id 1hW7vI-0007wg-Fn; Wed, 29 May 2019 20:23:56 -0300
From: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
To: Linux Doc Mailing List <linux-doc@vger.kernel.org>
Cc: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	linux-kernel@vger.kernel.org,
	Jonathan Corbet <corbet@lwn.net>,
	xen-devel@lists.xenproject.org,
	linux-kselftest@vger.kernel.org,
	linux-amlogic@lists.infradead.org,
	linux-gpio@vger.kernel.org,
	linux-pm@vger.kernel.org,
	devel@driverdev.osuosl.org,
	keyrings@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	linux-integrity@vger.kernel.org,
	linux-mtd@lists.infradead.org,
	patches@opensource.cirrus.com,
	devicetree@vger.kernel.org,
	netdev@vger.kernel.org,
	alsa-devel@alsa-project.org,
	devel@acpica.org,
	virtualization@lists.linux-foundation.org,
	linux-mm@kvack.org,
	linux-pci@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-security-module@vger.kernel.org,
	linux-i2c@vger.kernel.org,
	kvm@vger.kernel.org,
	bpf@vger.kernel.org,
	x86@kernel.org
Subject: [PATCH 00/22] Some documentation fixes
Date: Wed, 29 May 2019 20:23:31 -0300
Message-Id: <cover.1559171394.git.mchehab+samsung@kernel.org>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Fix several warnings and broken links.

This series was generated against linux-next, but was rebased to be applied at
docs-next. It should apply cleanly on either tree.

There's a git tree with all of them applied on the top of docs/docs-next
at:

https://git.linuxtv.org/mchehab/experimental.git/log/?h=fix_doc_links_v2


Mauro Carvalho Chehab (21):
  ABI: sysfs-devices-system-cpu: point to the right docs
  isdn: mISDN: remove a bogus reference to a non-existing doc
  dt: fix broken references to nand.txt
  docs: zh_CN: get rid of basic_profiling.txt
  doc: it_IT: fix reference to magic-number.rst
  docs: mm: numaperf.rst: get rid of a build warning
  docs: bpf: get rid of two warnings
  docs: mark orphan documents as such
  docs: amd-memory-encryption.rst get rid of warnings
  gpu: amdgpu: fix broken amdgpu_dma_buf.c references
  gpu: i915.rst: Fix references to renamed files
  docs: zh_CN: avoid duplicate citation references
  docs: vm: hmm.rst: fix some warnings
  docs: it: license-rules.rst: get rid of warnings
  docs: gpio: driver.rst: fix a bad tag
  docs: soundwire: locking: fix tags for a code-block
  docs: security: trusted-encrypted.rst: fix code-block tag
  docs: security: core.rst: Fix several warnings
  docs: net: dpio-driver.rst: fix two codeblock warnings
  docs: net: sja1105.rst: fix table format
  docs: fix broken documentation links

Otto Sabart (1):
  mfd: madera: Fix bad reference to pinctrl.txt file

 .../ABI/testing/sysfs-devices-system-cpu      |  3 +-
 Documentation/accelerators/ocxl.rst           |  2 +
 Documentation/acpi/dsd/leds.txt               |  2 +-
 .../admin-guide/kernel-parameters.rst         |  6 +-
 .../admin-guide/kernel-parameters.txt         | 16 ++---
 Documentation/admin-guide/mm/numaperf.rst     |  5 +-
 Documentation/admin-guide/ras.rst             |  2 +-
 Documentation/arm/stm32/overview.rst          |  2 +
 .../arm/stm32/stm32f429-overview.rst          |  2 +
 .../arm/stm32/stm32f746-overview.rst          |  2 +
 .../arm/stm32/stm32f769-overview.rst          |  2 +
 .../arm/stm32/stm32h743-overview.rst          |  2 +
 .../arm/stm32/stm32mp157-overview.rst         |  2 +
 Documentation/bpf/btf.rst                     |  2 +
 .../bindings/mtd/amlogic,meson-nand.txt       |  2 +-
 .../devicetree/bindings/mtd/gpmc-nand.txt     |  2 +-
 .../devicetree/bindings/mtd/marvell-nand.txt  |  2 +-
 .../devicetree/bindings/mtd/tango-nand.txt    |  2 +-
 .../devicetree/bindings/net/fsl-enetc.txt     |  7 +-
 .../bindings/pci/amlogic,meson-pcie.txt       |  2 +-
 .../regulator/qcom,rpmh-regulator.txt         |  2 +-
 .../devicetree/booting-without-of.txt         |  2 +-
 Documentation/driver-api/gpio/board.rst       |  2 +-
 Documentation/driver-api/gpio/consumer.rst    |  2 +-
 Documentation/driver-api/gpio/driver.rst      |  2 +-
 .../driver-api/soundwire/locking.rst          |  4 +-
 .../firmware-guide/acpi/enumeration.rst       |  2 +-
 .../firmware-guide/acpi/method-tracing.rst    |  2 +-
 Documentation/gpu/amdgpu.rst                  |  4 +-
 Documentation/gpu/i915.rst                    |  6 +-
 Documentation/gpu/msm-crash-dump.rst          |  2 +
 Documentation/i2c/instantiating-devices       |  2 +-
 Documentation/interconnect/interconnect.rst   |  2 +
 Documentation/laptops/lg-laptop.rst           |  2 +
 .../freescale/dpaa2/dpio-driver.rst           |  4 +-
 Documentation/networking/dsa/sja1105.rst      |  6 +-
 Documentation/powerpc/isa-versions.rst        |  2 +
 Documentation/security/keys/core.rst          | 16 +++--
 .../security/keys/trusted-encrypted.rst       |  4 +-
 Documentation/sysctl/kernel.txt               |  4 +-
 .../translations/it_IT/process/howto.rst      |  2 +-
 .../it_IT/process/license-rules.rst           | 28 ++++----
 .../it_IT/process/magic-number.rst            |  2 +-
 .../it_IT/process/stable-kernel-rules.rst     |  4 +-
 .../translations/zh_CN/basic_profiling.txt    | 71 -------------------
 .../translations/zh_CN/process/4.Coding.rst   |  2 +-
 .../zh_CN/process/management-style.rst        |  4 +-
 .../zh_CN/process/programming-language.rst    | 28 ++++----
 .../virtual/kvm/amd-memory-encryption.rst     |  5 ++
 Documentation/virtual/kvm/vcpu-requests.rst   |  2 +
 Documentation/vm/hmm.rst                      |  9 ++-
 Documentation/x86/x86_64/5level-paging.rst    |  2 +-
 Documentation/x86/x86_64/boot-options.rst     |  4 +-
 .../x86/x86_64/fake-numa-for-cpusets.rst      |  2 +-
 MAINTAINERS                                   |  6 +-
 arch/arm/Kconfig                              |  2 +-
 arch/arm64/kernel/kexec_image.c               |  2 +-
 arch/powerpc/Kconfig                          |  2 +-
 arch/x86/Kconfig                              | 16 ++---
 arch/x86/Kconfig.debug                        |  2 +-
 arch/x86/boot/header.S                        |  2 +-
 arch/x86/entry/entry_64.S                     |  2 +-
 arch/x86/include/asm/bootparam_utils.h        |  2 +-
 arch/x86/include/asm/page_64_types.h          |  2 +-
 arch/x86/include/asm/pgtable_64_types.h       |  2 +-
 arch/x86/kernel/cpu/microcode/amd.c           |  2 +-
 arch/x86/kernel/kexec-bzimage64.c             |  2 +-
 arch/x86/kernel/pci-dma.c                     |  2 +-
 arch/x86/mm/tlb.c                             |  2 +-
 arch/x86/platform/pvh/enlighten.c             |  2 +-
 drivers/acpi/Kconfig                          | 10 +--
 drivers/isdn/mISDN/dsp_core.c                 |  2 -
 drivers/net/ethernet/faraday/ftgmac100.c      |  2 +-
 .../fieldbus/Documentation/fieldbus_dev.txt   |  4 +-
 drivers/vhost/vhost.c                         |  2 +-
 include/acpi/acpi_drivers.h                   |  2 +-
 include/linux/fs_context.h                    |  2 +-
 include/linux/lsm_hooks.h                     |  2 +-
 include/linux/mfd/madera/pdata.h              |  3 +-
 mm/Kconfig                                    |  2 +-
 security/Kconfig                              |  2 +-
 tools/include/linux/err.h                     |  2 +-
 .../Documentation/stack-validation.txt        |  4 +-
 tools/testing/selftests/x86/protection_keys.c |  2 +-
 84 files changed, 183 insertions(+), 212 deletions(-)
 delete mode 100644 Documentation/translations/zh_CN/basic_profiling.txt

-- 
2.21.0


