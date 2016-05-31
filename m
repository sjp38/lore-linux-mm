Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 59D58828E1
	for <linux-mm@kvack.org>; Tue, 31 May 2016 09:15:08 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g64so308140821pfb.2
        for <linux-mm@kvack.org>; Tue, 31 May 2016 06:15:08 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p184si7669051pfb.252.2016.05.31.06.15.07
        for <linux-mm@kvack.org>;
        Tue, 31 May 2016 06:15:07 -0700 (PDT)
Date: Tue, 31 May 2016 14:15:20 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [BUG] Page allocation failures with newest kernels
Message-ID: <20160531131520.GI24936@arm.com>
References: <CAPv3WKcVsWBgHHC3UPNcbka2JUmN4CTw1Ym4BR1=1V9=B9av5Q@mail.gmail.com>
 <574D64A0.2070207@arm.com>
 <CAPv3WKdYdwpi3k5eY86qibfprMFwkYOkDwHOsNydp=0sTV3mgg@mail.gmail.com>
 <60e8df74202e40b28a4d53dbc7fd0b22@IL-EXCH02.marvell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <60e8df74202e40b28a4d53dbc7fd0b22@IL-EXCH02.marvell.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yehuda Yitschak <yehuday@marvell.com>
Cc: Marcin Wojtas <mw@semihalf.com>, Robin Murphy <robin.murphy@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Lior Amsalem <alior@marvell.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Catalin Marinas <catalin.marinas@arm.com>, Arnd Bergmann <arnd@arndb.de>, Grzegorz Jaszczyk <jaz@semihalf.com>, Nadav Haklai <nadavh@marvell.com>, Tomasz Nowicki <tn@semihalf.com>, Gregory =?iso-8859-1?Q?Cl=E9ment?= <gregory.clement@free-electrons.com>

On Tue, May 31, 2016 at 01:10:44PM +0000, Yehuda Yitschak wrote:
> During some of the stress tests we also came across a different warning
> from the arm64  page management code
> It looks like a race is detected between HW and SW marking a bit in the PTE

A72 (which I believe is the CPU in that SoC) is a v8.0 CPU and therefore
doesn't have hardware DBM.

> Not sure it's really related but I thought it might give a clue on the issue
> http://pastebin.com/ASv19vZP

There have been a few patches from Catalin to fix up the hardware DBM
patches, so it might be worth trying to reproduce this failure with a
more recent kernel. I doubt this is related to the allocation failures,
however.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
