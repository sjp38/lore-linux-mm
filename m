From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14268.13703.716732.620692@dukat.scot.redhat.com>
Date: Thu, 19 Aug 1999 17:49:11 +0100 (BST)
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
In-Reply-To: <37BC07AC.76E81480@mandrakesoft.com>
References: <Pine.LNX.4.10.9908170212250.14570-100000@laser.random>
	<37BC07AC.76E81480@mandrakesoft.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thierry Vignaud <tvignaud@mandrakesoft.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, torvalds@transmeta.com, sct@redhat.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, x-linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 19 Aug 1999 13:33:32 +0000, Thierry Vignaud
<tvignaud@mandrakesoft.com> said:

> since only recent motherboard support more than 512Mb RAM, and since
> they used i686 (PPro, P2, P3), why not use the pse36 extension of
> these cpu that enable to stock the segment length on 24bits, which
> give 64To when mem unit is 4b page.  this'll make the limit much
> higher (say 128Mb RAM for the kernel space memory and 15,9To for the
> user space).  

The PAE36 extensions let you address 64GB of physical memory, but don't
change the fact that you still have a 32-bit user address space: the
user space is still limited to 3GB.

> This would break some api, but why not add foo_64 for each foo()
> function as glibc does for big files ?  As for standard api such as of
> libc, i don't think wa have to worry about. There are few Programs
> which want a lot of memory such as oracle.  For these, we may find a
> special way of accessing the mem (64bits pointers, 64bit mmap, ...)

The CPU doesn't support 64 bit pointers.  Kind of makes it a bit
inefficient to access the user memory if you have to make a system call
every time. :)

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
