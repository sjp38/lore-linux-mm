From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 0/5] Sizing zones and holes in an architecture independent manner V7
Date: Wed, 7 Jun 2006 12:16:24 +0200
References: <20060606134710.21419.48239.sendpatchset@skynet.skynet.ie> <200606071145.04938.ak@suse.de> <Pine.LNX.4.64.0606071059480.20653@skynet.skynet.ie>
In-Reply-To: <Pine.LNX.4.64.0606071059480.20653@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200606071216.24640.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@osdl.org>, davej@codemonkey.org.uk, tony.luck@intel.com, bob.picco@hp.com, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Right now, x86_64 seems to be the only arch that accounts for the kernel 
> image and memmap as holes so I would consider it to be unusual.

s/unusual/more advanced/

> For memory  
> hot-add, new memmaps are allocated using kmalloc() and are not accounted 
> for as holes. 

At least in the standard (non sparsemem) hotadd they are accounted afaik.

> So, on x86_64, some memmaps are holes and others are not. 
> 
> Why is it a performance regression if the image and memmap is accounted 
> for as holes? How are those regions different from any other kernel 
> allocation or bootmem allocations for example which are not accounted as 
> holes? 

They are comparatively big and cannot be freed.

>If you are sure that it makes a measurable difference to performance,

There was at least one benchmark/use case where it made a significant
difference, can't remember the exact numbers though.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
