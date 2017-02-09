Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8FF266B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 11:39:32 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id o16so8835963wra.2
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 08:39:32 -0800 (PST)
Received: from mail.free-electrons.com (mail.free-electrons.com. [62.4.15.54])
        by mx.google.com with ESMTP id c133si6780830wme.80.2017.02.09.08.39.31
        for <linux-mm@kvack.org>;
        Thu, 09 Feb 2017 08:39:31 -0800 (PST)
From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCH 0/8] ARM: sun8i: a33: Mali improvements
Date: Thu,  9 Feb 2017 17:39:14 +0100
Message-Id: <cover.7101c7323e6f22e281ad70b93488cf44caca4ca0.1486655917.git-series.maxime.ripard@free-electrons.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Chen-Yu Tsai <wens@csie.org>, Maxime Ripard <maxime.ripard@free-electrons.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: dri-devel@lists.freedesktop.org, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

Hi,

This serie is building on the recently merged bindings for the ARM Mali
Utgard GPU.

The two features that are supported with this serie are DVFS and the fbdev
support. The first one uses devfreq and is pretty standard, the only
addition being the generic OPP mechanism we have, plus some DT and Kconfig
patches.

Running on framebuffer is a bit more tedious, since we need to access the
CMA memory region size and base. This is quite trivial to do as well
through the memory-region bindings, but require to export a few symbols
along the way to make sure our module builds properly.

Let me know what you think,
Maxime

Maxime Ripard (8):
  ARM: sun8i: Fix the mali clock rate
  dt-bindings: gpu: mali: Add optional memory-region
  mm: cma: Export a few symbols
  drm/sun4i: Grab reserved memory region
  ARM: sun8i: a33: Add shared display memory pool
  dt-bindings: gpu: mali: Add optional OPPs
  ARM: sunxi: Select PM_OPP
  ARM: sun8i: a33: Add the Mali OPPs

 Documentation/devicetree/bindings/gpu/arm,mali-utgard.txt |  8 ++-
 arch/arm/boot/dts/sun8i-a23-a33.dtsi                      |  2 +-
 arch/arm/boot/dts/sun8i-a33.dtsi                          | 34 ++++++++-
 arch/arm/mach-sunxi/Kconfig                               |  1 +-
 drivers/base/dma-contiguous.c                             |  1 +-
 drivers/gpu/drm/sun4i/sun4i_drv.c                         | 19 ++--
 mm/cma.c                                                  |  2 +-
 7 files changed, 61 insertions(+), 6 deletions(-)

base-commit: a2138ce584d59571dd18a6cf3417cb90be7625d8
-- 
git-series 0.8.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
