Message-ID: <A91A08D00A4FD2119BD500104B55BDF6021A65EC@pdbh936a.pdb.siemens.de>
From: "Wichert, Gerhard" <Gerhard.Wichert@pdb.siemens.de>
Subject: AW: [bigmem-patch] 4GB with Linux on IA32
Date: Tue, 17 Aug 1999 10:17:50 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>, Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: alan@lxorguk.ukuu.org.uk, torvalds@transmeta.com, sct@redhat.com, "Wichert, Gerhard" <Gerhard.Wichert@pdb.siemens.de>, "Gerhard, Winfried" <Winfried.Gerhard@pdb.siemens.de>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


> -----Ursprungliche Nachricht-----
> Von: Andrea Arcangeli [mailto:andrea@suse.de]
> Gesendet am: Dienstag, 17. August 1999 01:50
> An: Kanoj Sarcar
> Cc: alan@lxorguk.ukuu.org.uk; torvalds@transmeta.com; sct@redhat.com;
> Gerhard.Wichert@pdb.siemens.de; Winfried.Gerhard@pdb.siemens.de;
> linux-kernel@vger.rutgers.edu; linux-mm@kvack.org
> Betreff: Re: [bigmem-patch] 4GB with Linux on IA32
> 
> On Mon, 16 Aug 1999, Kanoj Sarcar wrote:
> 
> >I was also talking about drivers which assume that all of memory is
> >direct mapped. For example, __va and __pa assume this. There 
> might be 
> >other macros/procedures which have the same assumption built in. 
> >Basically, anything that is dependent on PAGE_OFFSET needs to be
> >checked. 
> 
> Only places that may deal with bigmem pages and the core of the kernel
> must be checked. I don't exclude there still something to fix 
> (as happened
> with kernel/ptrace.c and /proc/*/mem) but with the current design we
> shouldn't need to touch the device drivers at all.

The only bigmem pages a driver will see are pages from the user process
dedicated for I/O. The driver will use the macros to get the physical
address to build the scatter/gather list for DMA. In this case the macros
will work correctly because of the wrap around in the 32 bit address space.
For private buffers the driver will get space in the low memory, therefore
the macros will work as usual. 

> 
> The only real problem currently seems to be raw-io to me... (hints?)
> 
> Andrea
> 

Gerhard.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
