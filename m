From: "Dannie Gay" <dang@broadcom.com>
Subject: loading and executing a binary image (user mode) from memory
Date: Thu, 13 Feb 2003 18:34:31 -0500
Message-ID: <NDBBILGLJCKBNGMNECMOCEDFILAA.dang@broadcom.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-questions-only@ssc.com, david@kasey.umkc.edu, Dannie Gay <dang@broadcom.com>
List-ID: <linux-mm.kvack.org>

Need assistance with this embedded linux project:

I want to decompress (from flash) a application into memory and execute it.
Ideally I want to simply jump to the starting location and run.  I've
already successfully allocated the required amount of memory (on bootup)
with alloc_bootmem_pages() from the kernel and decompress the image from
flash and load it into my allocated memory (free from kernel tampering).
My user mode application loads from a small initial ram disk, maps the
allocated memory into my process space and marks it as read/execute via mmap
PROT_READ|PROT_EXEC.  The problem is what kind of binary image is required
to be built which would allow simply jumping to this location?  Can a
particular binary image be built with gcc that is possition independant and
free from the file system requirements imposed upon do_execve?

I'm stuck here, has anyone done this sort of thing?

thanks,

dang




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
