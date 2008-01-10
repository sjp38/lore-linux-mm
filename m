Date: Thu, 10 Jan 2008 07:16:12 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [kvm-devel] mmu notifiers
Message-ID: <20080110131612.GA1933@sgi.com>
References: <20080109181908.GS6958@v2.random> <Pine.LNX.4.64.0801091352320.12335@schroedinger.engr.sgi.com> <47860512.3040607@qumranet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <47860512.3040607@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@qumranet.com>
Cc: Christoph Lameter <clameter@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, kvm-devel@lists.sourceforge.net, linux-mm@kvack.org, Daniel J Blueman <daniel.blueman@quadrics.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 10, 2008 at 01:44:18PM +0200, Avi Kivity wrote:
> Christoph Lameter wrote:
>> On Wed, 9 Jan 2008, Andrea Arcangeli wrote:
>>
>>   
>>> This patch is a first basic implementation of the mmu notifiers. More
>>> methods can be added in the future.
>>>
>>> In short when the linux VM decides to free a page, it will unmap it
>>> from the linux pagetables. However when a page is mapped not just by
>>> the regular linux ptes, but also from the shadow pagetables, it's
>>> currently unfreeable by the linux VM.
>>>     
>>
>> Such a patch would also address issues that SGI has with exporting 
>> mappings via XPMEM. Plus a variety of other uses. Go ahead and lets do 
>> more in this area.
>>
>> Are the KVM folks interested in exporting memory from one guest to 
>> another? That may also become possible with some of the work that we have 
>> in progress and that also requires a patch like this.
>>
>>   
>
> Actually sharing memory is possible even without this patch; one simply 
> mmap()s a file into the address space of both guests.  Or are you referring 
> to something else?

He is referring to the xpmem work SGI has pushed in the past.  It was
rejected precisely because this type functionality did not exist.  We were
trying to determine the cleanest yet smallest acceptable implementation
when this suddenly sprang up.  I would expect Dean Nelson or myself to
repost the xpmem patch set again based upon this patche.

> The patch does enable some nifty things; one example you may be familiar 
> with is using page migration to move a guest from one numa node to another.

xpmem allows one MPI rank to "export" his address space, a different
MPI rank to "import" that address space, and they share the same pages.
This allows sharing of things like stack and heap space.  XPMEM also
provides a mechanism to share that PFN information across partition
boundaries so the pages become available on a different host.  This,
of course, is dependent upon hardware that supports direct access to
the memory by the processor.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
