Message-ID: <0E3FA95632D6D047BA649F95DAB60E5705A70E61@exa-atlanta>
From: "Mukker, Atul" <Atulm@lsil.com>
Subject: RE: [PATCH] Avoiding fragmentation through different allocator
Date: Tue, 25 Jan 2005 09:02:34 -0500
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Andi Kleen' <ak@muc.de>, 'Steve Lord' <lord@xfs.org>
Cc: 'Marcelo Tosatti' <marcelo.tosatti@cyclades.com>, 'Mel Gorman' <mel@csn.ul.ie>, 'William Lee Irwin III' <wli@holomorphy.com>, 'Linux Memory Management List' <linux-mm@kvack.org>, 'Linux Kernel' <linux-kernel@vger.kernel.org>, 'Grant Grundler' <grundler@parisc-linux.org>, "Mukker, Atul" <Atulm@lsil.com>
List-ID: <linux-mm.kvack.org>

 
> e.g. performance on megaraid controllers (very popular 
> because a big PC vendor ships them) was always quite bad on 
> Linux. Up to the point that specific IO workloads run half as 
> fast on a megaraid compared to other controllers. I heard 
> they do work better on Windows.
> 
<snip>
> Ideally the Linux IO patterns would look similar to the 
> Windows IO patterns, then we could reuse all the 
> optimizations the controller vendors did for Windows :)

LSI would leave no stone unturned to make the performance better for
megaraid controllers under Linux. If you have some hard data in relation to
comparison of performance for adapters from other vendors, please share with
us. We would definitely strive to better it.

The megaraid driver is open source, do you see anything that driver can do
to improve performance. We would greatly appreciate any feedback in this
regard and definitely incorporate in the driver. The FW under Linux and
windows is same, so I do not see how the megaraid stack should perform
differently under Linux and windows?

Thanks

Atul Mukker
Architect, Drivers and BIOS
LSI Logic Corporation
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
