Date: Tue, 25 Jan 2005 14:27:57 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Avoiding fragmentation through different allocator
Message-ID: <20050125142757.GA20442@infradead.org>
References: <0E3FA95632D6D047BA649F95DAB60E5705A70E61@exa-atlanta> <41F65514.3040707@xfs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <41F65514.3040707@xfs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steve Lord <lord@xfs.org>
Cc: "Mukker, Atul" <Atulm@lsil.com>, 'Andi Kleen' <ak@muc.de>, 'Marcelo Tosatti' <marcelo.tosatti@cyclades.com>, 'Mel Gorman' <mel@csn.ul.ie>, 'William Lee Irwin III' <wli@holomorphy.com>, 'Linux Memory Management List' <linux-mm@kvack.org>, 'Linux Kernel' <linux-kernel@vger.kernel.org>, 'Grant Grundler' <grundler@parisc-linux.org>
List-ID: <linux-mm.kvack.org>

> It is not the driver per se, but the way the memory which is the I/O
> source/target is presented to the driver. In linux there is a good
> chance it will have to use more scatter gather elements to represent
> the same amount of data.

Note that a change made a few month ago after seeing issues with
aacraid means it's much more likely to see contingous memory,
there were some numbers on linux-scsi and/or linux-kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
