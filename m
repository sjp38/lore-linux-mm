Message-ID: <3C3972D4.56F4A1E2@loewe-komp.de>
Date: Mon, 07 Jan 2002 11:05:08 +0100
From: Peter =?iso-8859-1?Q?W=E4chtler?= <pwaechtler@loewe-komp.de>
MIME-Version: 1.0
Subject: Re: [PATCH] updated version of radix-tree pagecache
References: <20020105171234.A25383@caldera.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@caldera.de>
Cc: linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, velco@fadata.bg
List-ID: <linux-mm.kvack.org>

Christoph Hellwig schrieb:
> 
> [please Cc velco@fadata.bg and lkml on reply]
> 
> I've just uploaded an updated version of Momchil Velikov's patch for a
> scalable pagecache using radix trees.  The patch can be found at:
> 
> It contains a number of fixed and improvements by Momchil and me.
> 

Can you sum up the advantages of this implementation?
I think it scales better on "big systems" where otherwise you end up with many
pages on the same hash?

Is it beneficial for small systems? (I think not)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
