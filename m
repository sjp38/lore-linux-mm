Date: Wed, 20 Sep 2000 10:53:08 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: how to translate virtual memory addresss into physical address ?
Message-ID: <20000920105308.K4608@redhat.com>
References: <39C86AF6.1040200@SANgate.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <39C86AF6.1040200@SANgate.com>; from gabriel@SANgate.com on Wed, Sep 20, 2000 at 10:44:54AM +0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: BenHanokh Gabriel <gabriel@SANgate.com>
Cc: Linux-MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Sep 20, 2000 at 10:44:54AM +0300, BenHanokh Gabriel wrote:
> 
> how do i get in a kernel module the physical address from a virtual memory 
> addreess ( where the virual address can be either main-memory address or mmaped 
> pci memory) ?

When you say "main memory", do you mean user space virtual addresses
or just kernel space?

For kernel-space main memory, you just use virt_to_phys().

For pci memory, you usually don't do anything --- you *start* with the
physical address and work from there, creating a virtual address with
ioremap().  You can do the translation backwards, but only by walking
page tables.

You might want to use map_user_kiobuf() for user-space addresses if
you are running on 2.4 (or 2.2 with the raw IO patches).  I've got
diffs for a map_kernel_kiobuf() too, for 2.4 only.  Those will also
deal properly with things like locking user pages in memory and
dealing with high memory on Intel boxes.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
