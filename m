Message-ID: <20011218160439.98250.qmail@web12308.mail.yahoo.com>
Date: Tue, 18 Dec 2001 08:04:39 -0800 (PST)
From: Ravi K <kravi26@yahoo.com>
Subject: Re: Stealing memory pages.
In-Reply-To: <20011218070143.15173.qmail@mailFA5.rediffmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: amey d inamdar <iamey@rediffmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
  I guess you have to make sure that globals like
max_low_pfn, highstart_pfn, highend_pfn and max_mapnr
are consistent with your setup. Some of these are used
for validating page structures and in determining the
start address used by vmalloc(). Other than that, I
don't think there is any problem with this setup.
  Of course, someone will correct me if I am wrong
here..

-Regards,
 Ravi.

--- amey d inamdar <iamey@rediffmail.com> wrote:
> Hi,
>     We are a group of four students, working on a
> project, "Implementation of Network RAM". We want to
> add the remote pages to the address space of a
> process ( by Modifying page fault handler). 
>     For the same reason we need a fixed allocation
> of a pool of page frames on each machine, which will
> serve as source for NRAM pages. This pool on each
> machine will be handled by a "Server" which will be
> implemented as a kernel module.
>     So at the initialization only, we have to
> allocate the page frames to the module. We did it
> successfully as follows:
> 1)  After setting up mem_map ( array of page *),
> while freeing individual page we didn't give last
> few pages to the buddy deallocator.
> 2)  We individually marked all those pages
> non-reserved and stored virtual address of start of
> the first page frame. (__va(page)). The virtual
> address is part of kernel address space.
> 3) Now our server module will use this address and
> total no of pages, to manage allocation of pages to
> a remote process.
>    My question is that, whether blocking such
> virtual address space inside the kernel can cause
> harm to its functionality? The machine is still
> working fine, but are there any ill-effects of such
> page frame stealing?
>    thank you in anticipation.
> - Amey 


__________________________________________________
Do You Yahoo!?
Check out Yahoo! Shopping and Yahoo! Auctions for all of
your unique holiday gifts! Buy at http://shopping.yahoo.com
or bid at http://auctions.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
