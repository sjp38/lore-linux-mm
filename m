Message-ID: <41F65514.3040707@xfs.org>
Date: Tue, 25 Jan 2005 08:17:56 -0600
From: Steve Lord <lord@xfs.org>
MIME-Version: 1.0
Subject: Re: [PATCH] Avoiding fragmentation through different allocator
References: <0E3FA95632D6D047BA649F95DAB60E5705A70E61@exa-atlanta>
In-Reply-To: <0E3FA95632D6D047BA649F95DAB60E5705A70E61@exa-atlanta>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Mukker, Atul" <Atulm@lsil.com>
Cc: 'Andi Kleen' <ak@muc.de>, 'Marcelo Tosatti' <marcelo.tosatti@cyclades.com>, 'Mel Gorman' <mel@csn.ul.ie>, 'William Lee Irwin III' <wli@holomorphy.com>, 'Linux Memory Management List' <linux-mm@kvack.org>, 'Linux Kernel' <linux-kernel@vger.kernel.org>, 'Grant Grundler' <grundler@parisc-linux.org>
List-ID: <linux-mm.kvack.org>

Mukker, Atul wrote:

> 
> LSI would leave no stone unturned to make the performance better for
> megaraid controllers under Linux. If you have some hard data in relation to
> comparison of performance for adapters from other vendors, please share with
> us. We would definitely strive to better it.
> 
> The megaraid driver is open source, do you see anything that driver can do
> to improve performance. We would greatly appreciate any feedback in this
> regard and definitely incorporate in the driver. The FW under Linux and
> windows is same, so I do not see how the megaraid stack should perform
> differently under Linux and windows?

It is not the driver per se, but the way the memory which is the I/O
source/target is presented to the driver. In linux there is a good
chance it will have to use more scatter gather elements to represent
the same amount of data.

Steve
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
