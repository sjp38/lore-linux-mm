Date: Tue, 9 Apr 2002 10:59:12 +0530 (IST)
From: Sanket Rathi <sanket.rathi@cdac.ernet.in>
Subject: Re: Fwd: Re: How CPU(x86) resolve kernel address
In-Reply-To: <20020407025738.90777.qmail@web12307.mail.yahoo.com>
Message-ID: <Pine.GSO.4.10.10204091052060.13298-100000@mailhub.cdac.ernet.in>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ravi <kravi26@yahoo.com>, linux-mm@kvack.org
Cc: sanket.rathi@cdac.ernet.in
List-ID: <linux-mm.kvack.org>

thanks........... 
but i tried. i allocate memory buffers in application and pass their
address to driver. there i use the following 

 if (pgd_none(*(pgd = pgd_offset(current->mm,virtAddress))) ||

                pmd_none(*(pmd = pmd_offset(pgd, virtAddress))) ||

                pte_none(*(pte = pte_offset(pmd, virtAddress))) )
                {
                        printk("\nphysical address failed\n") ;
                        return (-1) ;
                }
                phyAddress = pte_page(*pte) ;
                printk("\nphysical address is %x",(unsigned
long)phyAddress) ;

where virtAddress is the address i passed from application so every time
phyAddress i got is start with somthing like (C1081234) which is actually
a kernel address space. why it is like so.

thanks in advance.
 

--- Sanket Rathi

--------------------------

The problem with people who have no viceis that
generally you can be pretty sure they're going 
to have some pretty annoying virtues.

On Sat, 6 Apr 2002, Ravi wrote:

>  
>  I didn't quite understand which part of my mail you were refering to.
> Would have been helpful if you added your comments under the related
> lines.
> 
> > so why it is like that, that when u traverse page table(threee level)
> > u will  find a address like a kernel address (something like
> > C0000000 + some address) 
>  
>  No, you will not find a kernel virtual address when you traverse a
> page table. The PTE is an actual physical address (logically or'ed with
> 12 flag bits).
> 
> >  and when u want to DMA u do virt_to_phys() that will 
> > remove upper bits but  not for CPU so what happen when this address
> > pass to CPU or there is  something else.
>   
>  The CPU has a memory management unit (MMU) which does the
> virtual-to-physical translation. You only need to load the right
> register with the base address of the page directory. Rest is handled
> by MMU, assuming you have set up your page tables correctly. 
>  In case of DMA, you are passing the address to a device/controller
> which deals only with physical addresses. So the driver writer has to
> do the MMU's job before passing an address to the device. This is just
> made simpler by the one-to-one mapping in Linux on i386 arcitecture. 
> 
> -Ravi.
> 
> 
> __________________________________________________
> Do You Yahoo!?
> Yahoo! Tax Center - online filing with TurboTax
> http://taxes.yahoo.com/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
