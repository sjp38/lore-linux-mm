Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8405F6B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 06:29:52 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id a143so300877741oii.2
        for <linux-mm@kvack.org>; Tue, 31 May 2016 03:29:52 -0700 (PDT)
Received: from mail-it0-x233.google.com (mail-it0-x233.google.com. [2607:f8b0:4001:c0b::233])
        by mx.google.com with ESMTPS id 34si43521415iot.168.2016.05.31.03.29.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 03:29:51 -0700 (PDT)
Received: by mail-it0-x233.google.com with SMTP id z123so47387225itg.0
        for <linux-mm@kvack.org>; Tue, 31 May 2016 03:29:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <574D64A0.2070207@arm.com>
References: <CAPv3WKcVsWBgHHC3UPNcbka2JUmN4CTw1Ym4BR1=1V9=B9av5Q@mail.gmail.com>
	<574D64A0.2070207@arm.com>
Date: Tue, 31 May 2016 12:29:51 +0200
Message-ID: <CAPv3WKdYdwpi3k5eY86qibfprMFwkYOkDwHOsNydp=0sTV3mgg@mail.gmail.com>
Subject: Re: [BUG] Page allocation failures with newest kernels
From: Marcin Wojtas <mw@semihalf.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Lior Amsalem <alior@marvell.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Yehuda Yitschak <yehuday@marvell.com>, Catalin Marinas <catalin.marinas@arm.com>, Arnd Bergmann <arnd@arndb.de>, Grzegorz Jaszczyk <jaz@semihalf.com>, Will Deacon <will.deacon@arm.com>, nadavh@marvell.com, Tomasz Nowicki <tn@semihalf.com>, =?UTF-8?Q?Gregory_Cl=C3=A9ment?= <gregory.clement@free-electrons.com>

Hi Robin,

>
> I remember there were some issues around 4.2 with the revision of the arm64
> atomic implementations affecting the cmpxchg_double() in SLUB, but those
> should all be fixed (and the symptoms tended to be considerably more fatal).
> A stronger candidate would be 97303480753e (which landed in 4.4), which has
> various knock-on effects on the layout of SLUB internals - does fiddling
> with L1_CACHE_SHIFT make any difference?
>

I'll check the commits, thanks. I forgot to add L1_CACHE_SHIFT was my
first suspect - I had spent a long time debugging network controller,
which stopped working because of this change - L1_CACHE_BYTES (and
hence NET_SKB_PAD) not fitting HW constraints. Anyway reverting it
didn't help at all for page alloc issue.

Best regards,
Marcin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
