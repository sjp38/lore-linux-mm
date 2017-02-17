Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 38489440608
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 10:56:47 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id u63so2718434wmu.0
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 07:56:47 -0800 (PST)
Received: from smtp.math.uni-bielefeld.de (smtp.math.uni-bielefeld.de. [129.70.45.10])
        by mx.google.com with ESMTPS id q4si13741678wrc.328.2017.02.17.07.56.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 07:56:46 -0800 (PST)
Subject: Re: [PATCH 0/8] ARM: sun8i: a33: Mali improvements
References: <10fd28cb-269a-ec38-ecfb-b7c86be3e716@math.uni-bielefeld.de>
 <20170216184524.cxcy2ux37yrwutla@lukather>
 <2cecfc48-576f-3888-08aa-1fe2edc3c752@math.uni-bielefeld.de>
 <20170217154219.d4z2gylzcrzntlt3@piout.net>
From: Tobias Jakobi <tjakobi@math.uni-bielefeld.de>
Message-ID: <1c13f7a8-b355-b985-c02f-a50bebfc86a7@math.uni-bielefeld.de>
Date: Fri, 17 Feb 2017 16:56:44 +0100
MIME-Version: 1.0
In-Reply-To: <20170217154219.d4z2gylzcrzntlt3@piout.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Cc: Maxime Ripard <maxime.ripard@free-electrons.com>, Mark Rutland <mark.rutland@arm.com>, thomas.petazzoni@free-electrons.com, devicetree@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, ML dri-devel <dri-devel@lists.freedesktop.org>, linux-mm@kvack.org, wens@csie.org, Rob Herring <robh+dt@kernel.org>, linux-arm-kernel@lists.infradead.org

Alexandre Belloni wrote:
> On 17/02/2017 at 13:45:44 +0100, Tobias Jakobi wrote:
>>> The device tree is a representation of the hardware itself. The state
>>> of the driver support doesn't change the hardware you're running on,
>>> just like your BIOS/UEFI on x86 won't change the device it reports to
>>> Linux based on whether it has a driver for it.
>> Like Emil already said, the new bindings and the DT entries are solely
>> introduced to support a proprietary out-of-tree module.
>>
> 
> Because device tree describes the hardware, the added binding doesn't
> support any particular module. The eventually upstreamed drvier will
> share the same bindings.
OK, can we then agree that we _only_ merge the bindings and the entries,
once this driver is upstream?

Driver upstreaming and DT work go hand-in-hand. It's usually after a lot
of discussion that new bindings get finalised. And for that discussion
to happen we need to know how the driver uses the information from the
DT. Otherwise we have no way to evaluate if the description is in any
way "appropriate".

And no, I don't follow the "DT is a separate/independent thing" thought.
It maybe is in an ideal world, but we've seen it now often enough that
bindings turned out to be poorly designed, even though they looked fine
at first.

With best wishes,
Tobias


> 
>> The current workflow when introducing new DT entries is the following:
>> - upstream a driver that uses the entries
>> - THEN add the new entries
>>
> 
> Exactly not, if you do that, checkpatch will complain loudly. Because
> you must not add a driver using bindings that are not documented first.
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
