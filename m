Subject: Re: loading and executing a binary image (user mode) from memory
References: <NDBBILGLJCKBNGMNECMOCEDFILAA.dang@broadcom.com>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 14 Feb 2003 08:45:14 -0700
In-Reply-To: <NDBBILGLJCKBNGMNECMOCEDFILAA.dang@broadcom.com>
Message-ID: <m1of5e7to5.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dannie Gay <dang@broadcom.com>
Cc: linux-mm@kvack.org, linux-questions-only@ssc.com, david@kasey.umkc.edu
List-ID: <linux-mm.kvack.org>

"Dannie Gay" <dang@broadcom.com> writes:

> Need assistance with this embedded linux project:

I would suggest jffs2, as it does compression and you can run it
directly out of flash.
 
> I want to decompress (from flash) a application into memory and execute it.
> Ideally I want to simply jump to the starting location and run.  I've
> already successfully allocated the required amount of memory (on bootup)
> with alloc_bootmem_pages() from the kernel and decompress the image from
> flash and load it into my allocated memory (free from kernel tampering).
> My user mode application loads from a small initial ram disk, maps the
> allocated memory into my process space and marks it as read/execute via mmap
> PROT_READ|PROT_EXEC.  The problem is what kind of binary image is required
> to be built which would allow simply jumping to this location?  Can a
> particular binary image be built with gcc that is possition independant and
> free from the file system requirements imposed upon do_execve?

Generally linux has virtual memory so you don't need to be position independent.
And if you are running on a port without a mmu it a standard binary there should
already be position independent.

> I'm stuck here, has anyone done this sort of thing?

Placing filesystems in flash is routine....

The exact details of what you want sound fuzzy and silly. But the net
effect does not sound hard.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
