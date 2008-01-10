Message-ID: <47860512.3040607@qumranet.com>
Date: Thu, 10 Jan 2008 13:44:18 +0200
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [kvm-devel] mmu notifiers
References: <20080109181908.GS6958@v2.random> <Pine.LNX.4.64.0801091352320.12335@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0801091352320.12335@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, kvm-devel@lists.sourceforge.net, linux-mm@kvack.org, Daniel J Blueman <daniel.blueman@quadrics.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Wed, 9 Jan 2008, Andrea Arcangeli wrote:
>
>   
>> This patch is a first basic implementation of the mmu notifiers. More
>> methods can be added in the future.
>>
>> In short when the linux VM decides to free a page, it will unmap it
>> from the linux pagetables. However when a page is mapped not just by
>> the regular linux ptes, but also from the shadow pagetables, it's
>> currently unfreeable by the linux VM.
>>     
>
> Such a patch would also address issues that SGI has with exporting 
> mappings via XPMEM. Plus a variety of other uses. Go ahead and lets do 
> more in this area.
>
> Are the KVM folks interested in exporting memory from one guest to 
> another? That may also become possible with some of the work that we have 
> in progress and that also requires a patch like this.
>
>   

Actually sharing memory is possible even without this patch; one simply 
mmap()s a file into the address space of both guests.  Or are you 
referring to something else?

The patch does enable some nifty things; one example you may be familiar 
with is using page migration to move a guest from one numa node to another.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
