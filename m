Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id EAC816B03D0
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 18:42:09 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id d13so1977452oib.3
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 15:42:09 -0800 (PST)
Received: from mail-oi0-f68.google.com (mail-oi0-f68.google.com. [209.85.218.68])
        by mx.google.com with ESMTPS id f19si2454007oib.312.2017.02.15.15.42.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 15:42:09 -0800 (PST)
Received: by mail-oi0-f68.google.com with SMTP id w144so126852oiw.1
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 15:42:09 -0800 (PST)
Date: Wed, 15 Feb 2017 17:42:07 -0600
From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 6/8] dt-bindings: gpu: mali: Add optional OPPs
Message-ID: <20170215234207.xyuw3wxryi3fdq3o@rob-hp-laptop>
References: <cover.7101c7323e6f22e281ad70b93488cf44caca4ca0.1486655917.git-series.maxime.ripard@free-electrons.com>
 <29cb6b892a6e7002d2f6271157a5efa648b0dd9b.1486655917.git-series.maxime.ripard@free-electrons.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <29cb6b892a6e7002d2f6271157a5efa648b0dd9b.1486655917.git-series.maxime.ripard@free-electrons.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxime Ripard <maxime.ripard@free-electrons.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Chen-Yu Tsai <wens@csie.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, dri-devel@lists.freedesktop.org, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

On Thu, Feb 09, 2017 at 05:39:20PM +0100, Maxime Ripard wrote:
> The operating-points-v2 binding gives a way to provide the OPP of the GPU.
> Let's use it.
> 
> Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
> ---
>  Documentation/devicetree/bindings/gpu/arm,mali-utgard.txt | 4 ++++
>  1 file changed, 4 insertions(+), 0 deletions(-)

Bindings should not unnecessarily evolve. The h/w does not evolve in 
this way. This should have been part of the original binding given that 
it was just added.

Acked-by: Rob Herring <robh@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
