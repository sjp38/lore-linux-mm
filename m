Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id EA7706B03F0
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 07:45:46 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id q124so2027113wmg.2
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 04:45:46 -0800 (PST)
Received: from smtp.math.uni-bielefeld.de (smtp.math.uni-bielefeld.de. [129.70.45.10])
        by mx.google.com with ESMTPS id l15si13218498wrb.74.2017.02.17.04.45.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 04:45:45 -0800 (PST)
Subject: Re: [PATCH 0/8] ARM: sun8i: a33: Mali improvements
References: <10fd28cb-269a-ec38-ecfb-b7c86be3e716@math.uni-bielefeld.de>
 <20170216184524.cxcy2ux37yrwutla@lukather>
From: Tobias Jakobi <tjakobi@math.uni-bielefeld.de>
Message-ID: <2cecfc48-576f-3888-08aa-1fe2edc3c752@math.uni-bielefeld.de>
Date: Fri, 17 Feb 2017 13:45:44 +0100
MIME-Version: 1.0
In-Reply-To: <20170216184524.cxcy2ux37yrwutla@lukather>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxime Ripard <maxime.ripard@free-electrons.com>
Cc: ML dri-devel <dri-devel@lists.freedesktop.org>, Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, wens@csie.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, thomas.petazzoni@free-electrons.com, devicetree@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

Hello Maxime,

Maxime Ripard wrote:
> Hi,
> 
> On Thu, Feb 16, 2017 at 01:43:06PM +0100, Tobias Jakobi wrote:
>> I was wondering about the following. Wasn't there some strict
>> requirement about code going upstream, which also included that there
>> was a full open-source driver stack for it?
>>
>> I don't see how this is the case for Mali, neither in the kernel, nor in
>> userspace. I'm aware that the Mali kernel driver is open-source. But it
>> is not upstream, maintained out of tree, and won't land upstream in its
>> current form (no resemblence to a DRM driver at all). And let's not talk
>> about the userspace part.
>>
>> So, why should this be here?
> 
> The device tree is a representation of the hardware itself. The state
> of the driver support doesn't change the hardware you're running on,
> just like your BIOS/UEFI on x86 won't change the device it reports to
> Linux based on whether it has a driver for it.
Like Emil already said, the new bindings and the DT entries are solely
introduced to support a proprietary out-of-tree module.

The current workflow when introducing new DT entries is the following:
- upstream a driver that uses the entries
- THEN add the new entries

I'm against adding such entries without having any upstream "consumer".


With best wishes,
Tobias


> So yes, unfortunately, we don't have a driver upstream at the
> moment. But that doesn't prevent us from describing the hardware
> accurately.
> 
> Maxime
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
