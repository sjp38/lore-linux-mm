Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 206346B0038
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 16:56:16 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id h67so8771614lfg.3
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 13:56:16 -0800 (PST)
Received: from customer-2a00-7660-0ca7-0000-0000-0000-0000-0b1b.ip6.gigabit.dk (customer-2a00-7660-0ca7-0000-7597-99e7-4e1c-9fc0.ip6.gigabit.dk. [2a00:7660:ca7:0:7597:99e7:4e1c:9fc0])
        by mx.google.com with ESMTPS id o125si5572272lfo.317.2017.02.17.13.56.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 13:56:14 -0800 (PST)
Date: Fri, 17 Feb 2017 22:56:11 +0100
From: Rask Ingemann Lambertsen <rask@formelder.dk>
Subject: Re: [PATCH 0/8] ARM: sun8i: a33: Mali improvements
Message-ID: <20170217215611.2ft4rpnukbijcgqn@localhost>
References: <10fd28cb-269a-ec38-ecfb-b7c86be3e716@math.uni-bielefeld.de>
 <CACvgo51p+aqegjkbF6jGggwr+KXq_71w0VFzJvFAF6_egT1-kA@mail.gmail.com>
 <20170217154419.xr4n2ikp4li3c7co@lukather>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170217154419.xr4n2ikp4li3c7co@lukather>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxime Ripard <maxime.ripard@free-electrons.com>
Cc: Emil Velikov <emil.l.velikov@gmail.com>, Mark Rutland <mark.rutland@arm.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, devicetree <devicetree@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, ML dri-devel <dri-devel@lists.freedesktop.org>, linux-mm@kvack.org, Tobias Jakobi <tjakobi@math.uni-bielefeld.de>, Chen-Yu Tsai <wens@csie.org>, Rob Herring <robh+dt@kernel.org>, LAKML <linux-arm-kernel@lists.infradead.org>

On Fri, Feb 17, 2017 at 04:44:19PM +0100, Maxime Ripard wrote:
[...]
> We already have DT bindings for out of tree drivers, there's really
> nothing new here.

We have DT bindings for *hardware*, not for drivers. As stated in
Documentation/devicetree/usage-model.txt:

"The "Open Firmware Device Tree", or simply Device Tree (DT), is a data
structure and language for describing hardware.  More specifically, it
is a description of hardware that is readable by an operating system
so that the operating system doesn't need to hard code details of the
machine."

"2.1 High Level View
-------------------
The most important thing to understand is that the DT is simply a data
structure that describes the hardware."

-- 
Rask Ingemann Lambertsen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
