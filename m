Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 522B26B03CE
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 18:40:31 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id j49so1826468otb.7
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 15:40:31 -0800 (PST)
Received: from mail-oi0-f67.google.com (mail-oi0-f67.google.com. [209.85.218.67])
        by mx.google.com with ESMTPS id 16si2459151ote.231.2017.02.15.15.40.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 15:40:30 -0800 (PST)
Received: by mail-oi0-f67.google.com with SMTP id x84so120601oix.2
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 15:40:30 -0800 (PST)
Date: Wed, 15 Feb 2017 17:40:29 -0600
From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 8/8] ARM: sun8i: a33: Add the Mali OPPs
Message-ID: <20170215234029.3vfh25gxtvz44dsw@rob-hp-laptop>
References: <cover.7101c7323e6f22e281ad70b93488cf44caca4ca0.1486655917.git-series.maxime.ripard@free-electrons.com>
 <2e4a4f3f2f584f65f3c2d5e78f589015c651198d.1486655917.git-series.maxime.ripard@free-electrons.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2e4a4f3f2f584f65f3c2d5e78f589015c651198d.1486655917.git-series.maxime.ripard@free-electrons.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxime Ripard <maxime.ripard@free-electrons.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Chen-Yu Tsai <wens@csie.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, dri-devel@lists.freedesktop.org, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

On Thu, Feb 09, 2017 at 05:39:22PM +0100, Maxime Ripard wrote:
> The Mali GPU in the A33 has various operating frequencies used in the
> Allwinner BSP.
> 
> Add them to our DT.
> 
> Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
> ---
>  arch/arm/boot/dts/sun8i-a33.dtsi | 17 +++++++++++++++++
>  1 file changed, 17 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/arm/boot/dts/sun8i-a33.dtsi b/arch/arm/boot/dts/sun8i-a33.dtsi
> index 043b1b017276..e1b0abfee42f 100644
> --- a/arch/arm/boot/dts/sun8i-a33.dtsi
> +++ b/arch/arm/boot/dts/sun8i-a33.dtsi
> @@ -101,6 +101,22 @@
>  		status = "disabled";
>  	};
>  
> +	mali_opp_table: opp_table1 {

gpu-opp-table

> +		compatible = "operating-points-v2";
> +
> +		opp@144000000 {
> +			opp-hz = /bits/ 64 <144000000>;
> +		};
> +
> +		opp@240000000 {
> +			opp-hz = /bits/ 64 <240000000>;
> +		};
> +
> +		opp@384000000 {
> +			opp-hz = /bits/ 64 <384000000>;
> +		};
> +	};
> +
>  	memory {
>  		reg = <0x40000000 0x80000000>;
>  	};
> @@ -282,6 +298,7 @@
>  
>  &mali {
>  	memory-region = <&display_pool>;
> +	operating-points-v2 = <&mali_opp_table>;
>  };
>  
>  &pio {
> -- 
> git-series 0.8.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
