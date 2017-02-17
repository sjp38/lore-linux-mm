Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BA452440602
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 10:42:21 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id b51so2213145wrb.4
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 07:42:21 -0800 (PST)
Received: from mail.free-electrons.com (mail.free-electrons.com. [62.4.15.54])
        by mx.google.com with ESMTP id x1si9765212wrc.211.2017.02.17.07.42.20
        for <linux-mm@kvack.org>;
        Fri, 17 Feb 2017 07:42:20 -0800 (PST)
Date: Fri, 17 Feb 2017 16:42:19 +0100
From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Subject: Re: [PATCH 0/8] ARM: sun8i: a33: Mali improvements
Message-ID: <20170217154219.d4z2gylzcrzntlt3@piout.net>
References: <10fd28cb-269a-ec38-ecfb-b7c86be3e716@math.uni-bielefeld.de>
 <20170216184524.cxcy2ux37yrwutla@lukather>
 <2cecfc48-576f-3888-08aa-1fe2edc3c752@math.uni-bielefeld.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2cecfc48-576f-3888-08aa-1fe2edc3c752@math.uni-bielefeld.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tobias Jakobi <tjakobi@math.uni-bielefeld.de>
Cc: Maxime Ripard <maxime.ripard@free-electrons.com>, Mark Rutland <mark.rutland@arm.com>, thomas.petazzoni@free-electrons.com, devicetree@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, ML dri-devel <dri-devel@lists.freedesktop.org>, linux-mm@kvack.org, wens@csie.org, Rob Herring <robh+dt@kernel.org>, linux-arm-kernel@lists.infradead.org

On 17/02/2017 at 13:45:44 +0100, Tobias Jakobi wrote:
> > The device tree is a representation of the hardware itself. The state
> > of the driver support doesn't change the hardware you're running on,
> > just like your BIOS/UEFI on x86 won't change the device it reports to
> > Linux based on whether it has a driver for it.
> Like Emil already said, the new bindings and the DT entries are solely
> introduced to support a proprietary out-of-tree module.
> 

Because device tree describes the hardware, the added binding doesn't
support any particular module. The eventually upstreamed drvier will
share the same bindings.

> The current workflow when introducing new DT entries is the following:
> - upstream a driver that uses the entries
> - THEN add the new entries
> 

Exactly not, if you do that, checkpatch will complain loudly. Because
you must not add a driver using bindings that are not documented first.


-- 
Alexandre Belloni, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
