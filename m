Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id AAC20680FEA
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 07:43:09 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id yr2so3008267wjc.4
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 04:43:09 -0800 (PST)
Received: from smtp.math.uni-bielefeld.de (smtp.math.uni-bielefeld.de. [129.70.45.10])
        by mx.google.com with ESMTPS id z52si7831013wrb.20.2017.02.16.04.43.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Feb 2017 04:43:08 -0800 (PST)
From: Tobias Jakobi <tjakobi@math.uni-bielefeld.de>
Subject: Re: [PATCH 0/8] ARM: sun8i: a33: Mali improvements
Message-ID: <10fd28cb-269a-ec38-ecfb-b7c86be3e716@math.uni-bielefeld.de>
Date: Thu, 16 Feb 2017 13:43:06 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ML dri-devel <dri-devel@lists.freedesktop.org>
Cc: maxime.ripard@free-electrons.com, Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, wens@csie.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, thomas.petazzoni@free-electrons.com, devicetree@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

Hello,

I was wondering about the following. Wasn't there some strict
requirement about code going upstream, which also included that there
was a full open-source driver stack for it?

I don't see how this is the case for Mali, neither in the kernel, nor in
userspace. I'm aware that the Mali kernel driver is open-source. But it
is not upstream, maintained out of tree, and won't land upstream in its
current form (no resemblence to a DRM driver at all). And let's not talk
about the userspace part.

So, why should this be here?

With best wishes,
Tobias

P.S.: I'm signed up to dri-devel in digest mode, so sorry if this mail
doesn't properly show up in the corresponding ml thread.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
