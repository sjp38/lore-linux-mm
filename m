Date: Wed, 7 Jun 2006 10:42:20 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/5] Sizing zones and holes in an architecture independent
 manner V7
In-Reply-To: <20060606164311.27d4af98.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0606071030100.20653@skynet.skynet.ie>
References: <20060606134710.21419.48239.sendpatchset@skynet.skynet.ie>
 <20060606164311.27d4af98.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: davej@codemonkey.org.uk, tony.luck@intel.com, ak@suse.de, bob.picco@hp.com, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Jun 2006, Andrew Morton wrote:

> On Tue,  6 Jun 2006 14:47:10 +0100 (IST)
> Mel Gorman <mel@csn.ul.ie> wrote:
>
>> This is V7 of the patchset to size zones and memory holes in an
>> architecture-independent manner.
>
> I hope this won't deprive me of my 4 kbyte highmem zone.
>

heh, I think I found the thread you are on about, including your 4kb 
zone.

For future reference, the memory present in zones should be the same 
before and after the patches. Spanned pages and holes will be different on 
x86_64 because I don't account the kernel image and memmap as holes. 
Spanned pages may be different on ia64 as I start nodes on the first real 
page frame, not pfn 0 there and end them at the last real pfn. However, 
present pages should be the same before and after the patch :)

> I won't merge these patches for rc6-mm1 - we already have a few problems in
> this area which I don't think anyone understands yet.
>

I can't argue with that logic as it makes sense with the current 
uncertainties. I'll keep it rebased and resubmit later. In the meantime, 
I'll keep an eye out for issues in -mm that I can hit a kick or two.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
