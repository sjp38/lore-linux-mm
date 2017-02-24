Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D51326B0387
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 08:56:44 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id v63so39180839pgv.0
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 05:56:44 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id q9si7462977pli.125.2017.02.24.05.56.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Feb 2017 05:56:43 -0800 (PST)
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id E5C49201F2
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 13:56:42 +0000 (UTC)
Received: from mail-yw0-f170.google.com (mail-yw0-f170.google.com [209.85.161.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CE5592021A
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 13:56:39 +0000 (UTC)
Received: by mail-yw0-f170.google.com with SMTP id q127so9989561ywg.0
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 05:56:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1c13f7a8-b355-b985-c02f-a50bebfc86a7@math.uni-bielefeld.de>
References: <10fd28cb-269a-ec38-ecfb-b7c86be3e716@math.uni-bielefeld.de>
 <20170216184524.cxcy2ux37yrwutla@lukather> <2cecfc48-576f-3888-08aa-1fe2edc3c752@math.uni-bielefeld.de>
 <20170217154219.d4z2gylzcrzntlt3@piout.net> <1c13f7a8-b355-b985-c02f-a50bebfc86a7@math.uni-bielefeld.de>
From: Rob Herring <robh+dt@kernel.org>
Date: Fri, 24 Feb 2017 07:56:18 -0600
Message-ID: <CAL_JsqKYSKnYzddh+utr9BUth60xVM7fGN_6yxk3tuGTNabUmg@mail.gmail.com>
Subject: Re: [PATCH 0/8] ARM: sun8i: a33: Mali improvements
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tobias Jakobi <tjakobi@math.uni-bielefeld.de>
Cc: Alexandre Belloni <alexandre.belloni@free-electrons.com>, Maxime Ripard <maxime.ripard@free-electrons.com>, Mark Rutland <mark.rutland@arm.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, ML dri-devel <dri-devel@lists.freedesktop.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chen-Yu Tsai <wens@csie.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Fri, Feb 17, 2017 at 9:56 AM, Tobias Jakobi
<tjakobi@math.uni-bielefeld.de> wrote:
> Alexandre Belloni wrote:
>> On 17/02/2017 at 13:45:44 +0100, Tobias Jakobi wrote:
>>>> The device tree is a representation of the hardware itself. The state
>>>> of the driver support doesn't change the hardware you're running on,
>>>> just like your BIOS/UEFI on x86 won't change the device it reports to
>>>> Linux based on whether it has a driver for it.
>>> Like Emil already said, the new bindings and the DT entries are solely
>>> introduced to support a proprietary out-of-tree module.
>>>
>>
>> Because device tree describes the hardware, the added binding doesn't
>> support any particular module. The eventually upstreamed drvier will
>> share the same bindings.
> OK, can we then agree that we _only_ merge the bindings and the entries,
> once this driver is upstream?

Absolutely not.

> Driver upstreaming and DT work go hand-in-hand. It's usually after a lot
> of discussion that new bindings get finalised. And for that discussion
> to happen we need to know how the driver uses the information from the
> DT. Otherwise we have no way to evaluate if the description is in any
> way "appropriate".
>
> And no, I don't follow the "DT is a separate/independent thing" thought.
> It maybe is in an ideal world, but we've seen it now often enough that
> bindings turned out to be poorly designed, even though they looked fine
> at first.

Certainly, that happens (though arguably that was more often from lack
of review). But this one is self contained, using standard, existing
properties. I'm not worried about us getting it right. If this was
something new or different, then certainly yes I would want to see the
code.

Rob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
