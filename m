Date: 30 Apr 2003 22:14:38 -0000
Message-ID: <20030430221438.16759.qmail@webmail35.rediffmail.com>
MIME-Version: 1.0
From: "anand kumar" <a_santha@rediffmail.com>
Reply-To: "anand kumar" <a_santha@rediffmail.com>
Subject: Memory allocation problem
Content-type: text/plain;
	format=flowed
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

Hi,

We are developing a PCI driver for a specialized hardware which
needs blocks of physically contiguous memory regions of
32 KB. We need to allocate 514 such blocks for a total of 16 MB
We were using an ioctl implementation in the driver which uses
kmalloc() to allocate the required memory blocks. 
kmalloc()(GFP_KERNEL)
fails after allocating some 250 blocks of memory (probably due to 
fragmentation).
We then tried using __get_free_pages() and the result was the 
same.
Even though the free pages in zone NORMAL and DMA were 10000 and 
1500 respectively.

Are we hitting some limit because of fragmentation and are
not able to allocate 8 contiguous physical pages? We tried moving 
the
memory allocation in init_module and made the driver load during 
boot
time, during which allocation succeeds.

The kernel version we are using is 2.4.18 (Redhat 8.0) and the 
total
amount of memory available in the box is 128MB

Is there any other mechanism to allocate large amount of 
physically
contiguous memory blocks during normal run time of the driver? Is 
this
being addressed in later kernels.

Rgds
Anand




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
