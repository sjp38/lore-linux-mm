Date: Mon, 7 Jan 2002 03:03:44 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] updated version of radix-tree pagecache
Message-ID: <20020107030344.H10391@holomorphy.com>
References: <20020105171234.A25383@caldera.de> <3C3972D4.56F4A1E2@loewe-komp.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3C3972D4.56F4A1E2@loewe-komp.de>; from pwaechtler@loewe-komp.de on Mon, Jan 07, 2002 at 11:05:08AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter W?chtler <pwaechtler@loewe-komp.de>
Cc: Christoph Hellwig <hch@caldera.de>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, velco@fadata.bg
List-ID: <linux-mm.kvack.org>

Christoph Hellwig schrieb:
>> [please Cc velco@fadata.bg and lkml on reply]
>> 
>> I've just uploaded an updated version of Momchil Velikov's patch for a
>> scalable pagecache using radix trees.  The patch can be found at:
>> 
>> It contains a number of fixed and improvements by Momchil and me.

On Mon, Jan 07, 2002 at 11:05:08AM +0100, Peter W?chtler wrote:
> Can you sum up the advantages of this implementation?
> I think it scales better on "big systems" where otherwise you end up
> with many pages on the same hash?
> 
> Is it beneficial for small systems? (I think not)

I speculate this would be good for small systems as well as it reduces
the size of struct page by 2*sizeof(unsigned long) bytes, allowing more
incremental allocation of pagecache metadata. I haven't tried it on my
smaller systems yet (due to lack of disk space and needing to build the
cross-toolchains), though I'm now curious as to its exact behavior there.

Has anyone tried to do accounting on the radix tree metadata overhead yet?

Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
