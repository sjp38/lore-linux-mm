Message-ID: <39C890BC.7070308@SANgate.com>
Date: Wed, 20 Sep 2000 13:26:04 +0300
From: BenHanokh Gabriel <gabriel@SANgate.com>
MIME-Version: 1.0
Subject: Re: how to translate virtual memory addresss into physical address ?
References: <39C86AF6.1040200@SANgate.com> <20000920105308.K4608@redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linux-MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Stephen C. Tweedie wrote:

> Hi,
> 
> On Wed, Sep 20, 2000 at 10:44:54AM +0300, BenHanokh Gabriel wrote:
> > 
> > how do i get in a kernel module the physical address from a virtual memory 
> > addreess ( where the virual address can be either main-memory address or mmaped 
> > pci memory) ?
> 
> When you say "main memory", do you mean user space virtual addresses
> or just kernel space?
> 
my module will have to deal with user space virtual addresses which are mapped 
either to the computer "main-memory" or to a pci-device memory.


> For pci memory, you usually don't do anything --- you *start* with the
> physical address and work from there, creating a virtual address with
> ioremap().
this is only possible when my module is the pci-device driver, which is not the 
case here

>  You can do the translation backwards, but only by walking
> page tables.
how do i do this ? i tought that pci-memory is not pageable

> 
> You might want to use map_user_kiobuf() for user-space addresses if
> you are running on 2.4 (or 2.2 with the raw IO patches).  I've got
> diffs for a map_kernel_kiobuf() too, for 2.4 only.  Those will also
> deal properly with things like locking user pages in memory and
> dealing with high memory on Intel boxes.

will the map_user_kiobuf handle pci-device memory correctly (AFAIK locking pci 
memory is meaningless and that its memory is not split into pages ) ?




regards
Benhanokh Gabriel

-----------------------------------------------------------------------------
"If you think C++ is not overly complicated, just what is a
protected abstract virtual base class with a pure virtual private destructor,
and when was the last time you needed one?"
-- Tom Cargil, C++ Journal, Fall 1990. --

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
