Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6A9F86B0388
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 11:39:33 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id ez4so1938113wjd.2
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 08:39:33 -0800 (PST)
Received: from mail.free-electrons.com (mail.free-electrons.com. [62.4.15.54])
        by mx.google.com with ESMTP id p69si13460607wrb.124.2017.02.09.08.39.32
        for <linux-mm@kvack.org>;
        Thu, 09 Feb 2017 08:39:32 -0800 (PST)
From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCH 1/8] ARM: sun8i: Fix the mali clock rate
Date: Thu,  9 Feb 2017 17:39:15 +0100
Message-Id: <4830ced34cc83058f7cad123be67fecc624a99d6.1486655917.git-series.maxime.ripard@free-electrons.com>
In-Reply-To: <cover.7101c7323e6f22e281ad70b93488cf44caca4ca0.1486655917.git-series.maxime.ripard@free-electrons.com>
References: <cover.7101c7323e6f22e281ad70b93488cf44caca4ca0.1486655917.git-series.maxime.ripard@free-electrons.com>
In-Reply-To: <cover.7101c7323e6f22e281ad70b93488cf44caca4ca0.1486655917.git-series.maxime.ripard@free-electrons.com>
References: <cover.7101c7323e6f22e281ad70b93488cf44caca4ca0.1486655917.git-series.maxime.ripard@free-electrons.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Chen-Yu Tsai <wens@csie.org>, Maxime Ripard <maxime.ripard@free-electrons.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: dri-devel@lists.freedesktop.org, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

The Mali clock rate was improperly assumed to be 408MHz, while it was
really 384Mhz, 408MHz being the "extreme" frequency, and definitely not
stable.

Switch for the stable, correct frequency for the GPU.

Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
---
 arch/arm/boot/dts/sun8i-a23-a33.dtsi | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm/boot/dts/sun8i-a23-a33.dtsi b/arch/arm/boot/dts/sun8i-a23-a33.dtsi
index 35008b78d899..8a880ecc4dda 100644
--- a/arch/arm/boot/dts/sun8i-a23-a33.dtsi
+++ b/arch/arm/boot/dts/sun8i-a23-a33.dtsi
@@ -495,7 +495,7 @@
 			resets = <&ccu RST_BUS_GPU>;
 
 			assigned-clocks = <&ccu CLK_GPU>;
-			assigned-clock-rates = <408000000>;
+			assigned-clock-rates = <384000000>;
 		};
 
 		gic: interrupt-controller@01c81000 {
-- 
git-series 0.8.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
