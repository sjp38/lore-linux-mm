Message-ID: <37BC07AC.76E81480@mandrakesoft.com>
Date: Thu, 19 Aug 1999 13:33:32 +0000
From: Thierry Vignaud <tvignaud@mandrakesoft.com>
MIME-Version: 1.0
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
References: <Pine.LNX.4.10.9908170212250.14570-100000@laser.random>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, torvalds@transmeta.com, sct@redhat.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> 
> I uploaded a new bigmem-2.3.13-M patch here:
> 
>         ftp://e-mind.com/pub/andrea/kernel-patches/2.3.13/bigmem-2.3.13-M
> 
> (the raw-io must be avoided with bigmem enabled, since the protection I
> added in get_page_map() doesn't work right now)
> 
> If you'll avoid to do raw-io the patch should be safe and ready to use.

since only recent motherboard support more than 512Mb RAM, and since
they used i686 (PPro, P2, P3), why not use the pse36 extension of these
cpu that enable to stock the segment length on 24bits, which give 64To
when mem unit is 4b page.
this'll make the limit much higher (say 128Mb RAM for the kernel space
memory and 15,9To for the user space).
This would break some api, but why not add foo_64 for each foo()
function as glibc does for big files ?
As for standard api such as of libc, i don't think wa have to worry
about. There are few Programs which want a lot of memory such as oracle.
For these, we may find a special way of accessing the mem (64bits
pointers, 64bit mmap, ...)

-- 
MandrakeSoft          http://www.mandrakesoft.com/
	somewhere between the playstation and the super cray
			         	 --Thierry
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
