Subject: Re: [patch 3/8] mm: merge nopfn into fault
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20070524100729.GB28305@infradead.org>
References: <200705180737.l4I7b6cg010758@shell0.pdx.osdl.net>
	 <alpine.LFD.0.98.0705180817550.3890@woody.linux-foundation.org>
	 <1179963619.32247.991.camel@localhost.localdomain>
	 <20070524014223.GA22998@wotan.suse.de>
	 <alpine.LFD.0.98.0705231857090.3890@woody.linux-foundation.org>
	 <1179976659.32247.1026.camel@localhost.localdomain>
	 <1179977184.32247.1032.camel@localhost.localdomain>
	 <alpine.LFD.0.98.0705232028510.3890@woody.linux-foundation.org>
	 <20070524034557.GA20252@wotan.suse.de>
	 <20070524100729.GB28305@infradead.org>
Content-Type: text/plain
Date: Thu, 24 May 2007 20:15:09 +1000
Message-Id: <1180001709.32247.1060.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-05-24 at 11:07 +0100, Christoph Hellwig wrote:
> 
> Abusing __user for something entirely different is really dumb,
> just use the same __attribute__((noderef, address_space(N)) annotation
> that __user and __iomem use. but please use a different address_space 

But it not an abuse. It _is_ a user pointer

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
