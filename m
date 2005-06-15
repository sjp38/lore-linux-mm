Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j5FIrtk3028054
	for <linux-mm@kvack.org>; Wed, 15 Jun 2005 14:53:55 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j5FIrtwU250236
	for <linux-mm@kvack.org>; Wed, 15 Jun 2005 14:53:55 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j5FIrtuu024078
	for <linux-mm@kvack.org>; Wed, 15 Jun 2005 14:53:55 -0400
Subject: Re: 2.6.12-rc6-mm1 & 2K lun testing
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <42B073C1.3010908@yahoo.com.au>
References: <1118856977.4301.406.camel@dyn9047017072.beaverton.ibm.com>
	 <42B073C1.3010908@yahoo.com.au>
Content-Type: text/plain
Message-Id: <1118860223.4301.449.camel@dyn9047017072.beaverton.ibm.com>
Mime-Version: 1.0
Date: 15 Jun 2005 11:30:23 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2005-06-15 at 11:30, Nick Piggin wrote:
> Badari Pulavarty wrote:
> 
> > ------------------------------------------------------------------------
> > 
> > elm3b29 login: dd: page allocation failure. order:0, mode:0x20
> > 
> > Call Trace: <IRQ> <ffffffff801632ae>{__alloc_pages+990} <ffffffff801668da>{cache_grow+314}
> >        <ffffffff80166d7f>{cache_alloc_refill+543} <ffffffff80166e86>{kmem_cache_alloc+54}
> >        <ffffffff8033d021>{scsi_get_command+81} <ffffffff8034181d>{scsi_prep_fn+301}
> 
> They look like they're all in scsi_get_command.
> I would consider masking off __GFP_HIGH in the gfp_mask of that
> function, and setting __GFP_NOWARN. It looks like it has a mempoolish
> thingy in there, so perhaps it shouldn't delve so far into reserves.

You want me to take off GFP_HIGH ? or just set GFP_NOWARN with GFP_HIGH
?

- Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
