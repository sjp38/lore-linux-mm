Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0D94B6B03CC
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 18:37:54 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id u143so2033833oif.1
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 15:37:54 -0800 (PST)
Received: from mail-oi0-f67.google.com (mail-oi0-f67.google.com. [209.85.218.67])
        by mx.google.com with ESMTPS id y51si2457362otd.264.2017.02.15.15.37.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 15:37:53 -0800 (PST)
Received: by mail-oi0-f67.google.com with SMTP id x84so117310oix.2
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 15:37:53 -0800 (PST)
Date: Wed, 15 Feb 2017 17:37:51 -0600
From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 2/8] dt-bindings: gpu: mali: Add optional memory-region
Message-ID: <20170215233751.2sin5acaylsb5nqf@rob-hp-laptop>
References: <cover.7101c7323e6f22e281ad70b93488cf44caca4ca0.1486655917.git-series.maxime.ripard@free-electrons.com>
 <49fd36f667c5ae46b0724c8204eabc51014aab92.1486655917.git-series.maxime.ripard@free-electrons.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49fd36f667c5ae46b0724c8204eabc51014aab92.1486655917.git-series.maxime.ripard@free-electrons.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxime Ripard <maxime.ripard@free-electrons.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Chen-Yu Tsai <wens@csie.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, dri-devel@lists.freedesktop.org, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

On Thu, Feb 09, 2017 at 05:39:16PM +0100, Maxime Ripard wrote:
> The reserved memory bindings allow us to specify which memory areas our
> buffers can be allocated from.
> 
> Let's use it.

You didn't think of this when you just added Mali binding? 

> 
> Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
> ---
>  Documentation/devicetree/bindings/gpu/arm,mali-utgard.txt | 4 ++++
>  1 file changed, 4 insertions(+), 0 deletions(-)

Acked-by: Rob Herring <robh@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
