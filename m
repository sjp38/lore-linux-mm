Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B68746B0465
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 11:54:47 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id y7so4000062wrc.7
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 08:54:47 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id 191si1257565wmk.94.2017.02.16.08.54.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Feb 2017 08:54:46 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id u63so4033751wmu.2
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 08:54:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <10fd28cb-269a-ec38-ecfb-b7c86be3e716@math.uni-bielefeld.de>
References: <10fd28cb-269a-ec38-ecfb-b7c86be3e716@math.uni-bielefeld.de>
From: Emil Velikov <emil.l.velikov@gmail.com>
Date: Thu, 16 Feb 2017 16:54:45 +0000
Message-ID: <CACvgo51p+aqegjkbF6jGggwr+KXq_71w0VFzJvFAF6_egT1-kA@mail.gmail.com>
Subject: Re: [PATCH 0/8] ARM: sun8i: a33: Mali improvements
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tobias Jakobi <tjakobi@math.uni-bielefeld.de>
Cc: ML dri-devel <dri-devel@lists.freedesktop.org>, Mark Rutland <mark.rutland@arm.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, devicetree <devicetree@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Chen-Yu Tsai <wens@csie.org>, Rob Herring <robh+dt@kernel.org>, Maxime Ripard <maxime.ripard@free-electrons.com>, LAKML <linux-arm-kernel@lists.infradead.org>

On 16 February 2017 at 12:43, Tobias Jakobi
<tjakobi@math.uni-bielefeld.de> wrote:
> Hello,
>
> I was wondering about the following. Wasn't there some strict
> requirement about code going upstream, which also included that there
> was a full open-source driver stack for it?
>
> I don't see how this is the case for Mali, neither in the kernel, nor in
> userspace. I'm aware that the Mali kernel driver is open-source. But it
> is not upstream, maintained out of tree, and won't land upstream in its
> current form (no resemblence to a DRM driver at all). And let's not talk
> about the userspace part.
>
> So, why should this be here?
>
Have to agree with Tobias, here.

I can see the annoyance that Maxime and others have to go through to
their systems working.
At the same time, changing upstream kernel to suit out of tree
module(s) is not how things work. Right ?

Not to mention that the series adds stable ABI exclusively(?) used by
a module which does not seem to be in the process of getting merged.

Maxime, you're a great guy but I don't think this is suitable for
upstream... yet.

Regards,
Emil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
