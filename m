Message-ID: <39C8AA93.2080001@SANgate.com>
Date: Wed, 20 Sep 2000 15:16:19 +0300
From: BenHanokh Gabriel <gabriel@SANgate.com>
MIME-Version: 1.0
Subject: Re: how to translate virtual memory addresss into physical address ?
References: <39C86AF6.1040200@SANgate.com> <20000920105308.K4608@redhat.com> <39C890BC.7070308@SANgate.com> <20000920122007.M4608@redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linux-MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Stephen C. Tweedie wrote:


> 
> User space virtual addresses aren't necessarily mapped anywhere.  They
> can be swapped out, or for mmap they might not yet be faulted in at
> all.  You have to deal with all the complications of faulting the page
> and pinning it in memory if you want to deal with user virtual
> addresses.  I'd definitely use map_user_kiobuf for this, but that
> cannot yet deal with pci device memory.
how can i tell given a user-space virtual address, if that address is a "normal" 
main-memory address( which i can pass to map_user_kiobuf ) or that it is a pci 
mmaped address( which i have to deal with it myself ) ?

> > >  You can do the translation backwards, but only by walking
> > > page tables.
> > how do i do this ? i tought that pci-memory is not pageable
> 
> It's not pageable, but the virtual-to-physical address translation
> still uses page tables.
can you explain please  with more details how to translate from virtual 
user-space pci mmaped address to a physical address?

>"Non-pageable" just means that the page table
> entries cannot get paged out, not that they don't exist.
does the kernel have a page emulation for pci-memory ?

>> will the map_user_kiobuf handle pci-device memory correctly (AFAIK locking pci 
>> memory is meaningless and that its memory is not split into pages ) ?

> Not yet, no.  It can (and does) on the 2.2 version, but 2.4 encodes

>the kiobuf pages as "struct page *" pointers and we need to teach it

>how to generate such structs for dynamically-allocated memory regions
>such as PCI.
when do you think we are going to see implemenation of the map_user_kiobuf supporting pci-memory ?
will this be done for kernel 2.4 or only for the 2.5


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
