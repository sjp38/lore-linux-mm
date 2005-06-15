Message-ID: <42B07B44.9040408@yahoo.com.au>
Date: Thu, 16 Jun 2005 05:02:28 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: 2.6.12-rc6-mm1 & 2K lun testing
References: <1118856977.4301.406.camel@dyn9047017072.beaverton.ibm.com>	 <42B073C1.3010908@yahoo.com.au> <1118860223.4301.449.camel@dyn9047017072.beaverton.ibm.com>
In-Reply-To: <1118860223.4301.449.camel@dyn9047017072.beaverton.ibm.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Badari Pulavarty wrote:
> On Wed, 2005-06-15 at 11:30, Nick Piggin wrote:
> 
>>Badari Pulavarty wrote:
>>
>>
>>>------------------------------------------------------------------------
>>>
>>>elm3b29 login: dd: page allocation failure. order:0, mode:0x20
>>>
>>>Call Trace: <IRQ> <ffffffff801632ae>{__alloc_pages+990} <ffffffff801668da>{cache_grow+314}
>>>       <ffffffff80166d7f>{cache_alloc_refill+543} <ffffffff80166e86>{kmem_cache_alloc+54}
>>>       <ffffffff8033d021>{scsi_get_command+81} <ffffffff8034181d>{scsi_prep_fn+301}
>>
>>They look like they're all in scsi_get_command.
>>I would consider masking off __GFP_HIGH in the gfp_mask of that
>>function, and setting __GFP_NOWARN. It looks like it has a mempoolish
>>thingy in there, so perhaps it shouldn't delve so far into reserves.
> 
> 
> You want me to take off GFP_HIGH ? or just set GFP_NOWARN with GFP_HIGH
> ?
> 

Yeah, take off GFP_HIGH and set GFP_NOWARN (always). I would be
interested to see how that goes.

Obviously it won't eliminate your failures there (it will probably
produce more of them), however it might help the scsi command
allocation from overwhelming the system.

THanks,
Nick

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
