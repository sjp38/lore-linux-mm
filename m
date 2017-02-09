Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 238D528089F
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 11:39:35 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id kq3so1954432wjc.1
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 08:39:35 -0800 (PST)
Received: from mail.free-electrons.com (mail.free-electrons.com. [62.4.15.54])
        by mx.google.com with ESMTP id n19si13466269wra.126.2017.02.09.08.39.33
        for <linux-mm@kvack.org>;
        Thu, 09 Feb 2017 08:39:34 -0800 (PST)
From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCH 6/8] dt-bindings: gpu: mali: Add optional OPPs
Date: Thu,  9 Feb 2017 17:39:20 +0100
Message-Id: <29cb6b892a6e7002d2f6271157a5efa648b0dd9b.1486655917.git-series.maxime.ripard@free-electrons.com>
In-Reply-To: <cover.7101c7323e6f22e281ad70b93488cf44caca4ca0.1486655917.git-series.maxime.ripard@free-electrons.com>
References: <cover.7101c7323e6f22e281ad70b93488cf44caca4ca0.1486655917.git-series.maxime.ripard@free-electrons.com>
In-Reply-To: <cover.7101c7323e6f22e281ad70b93488cf44caca4ca0.1486655917.git-series.maxime.ripard@free-electrons.com>
References: <cover.7101c7323e6f22e281ad70b93488cf44caca4ca0.1486655917.git-series.maxime.ripard@free-electrons.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Chen-Yu Tsai <wens@csie.org>, Maxime Ripard <maxime.ripard@free-electrons.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: dri-devel@lists.freedesktop.org, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

The operating-points-v2 binding gives a way to provide the OPP of the GPU.
Let's use it.

Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
---
 Documentation/devicetree/bindings/gpu/arm,mali-utgard.txt | 4 ++++
 1 file changed, 4 insertions(+), 0 deletions(-)

diff --git a/Documentation/devicetree/bindings/gpu/arm,mali-utgard.txt b/Documentation/devicetree/bindings/gpu/arm,mali-utgard.txt
index 88df4a276607..2b6243e730f6 100644
--- a/Documentation/devicetree/bindings/gpu/arm,mali-utgard.txt
+++ b/Documentation/devicetree/bindings/gpu/arm,mali-utgard.txt
@@ -39,6 +39,10 @@ Optional properties:
     Memory region to allocate from, as defined in
     Documentation/devicetree/bindi/reserved-memory/reserved-memory.txt
 
+  - operating-points-v2:
+    Operating Points for the GPU, as defined in
+    Documentation/devicetree/bindings/opp/opp.txt
+
 Vendor-specific bindings
 ------------------------
 
-- 
git-series 0.8.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
