Date: Tue, 19 Nov 2002 22:24:51 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Porting to from Solaris 64bit to Linux 32B - 36B.
In-Reply-To: <C5BF7C2C6ADF24448763CC46235FB3A691C82E@ulysses.neocore.com>
Message-ID: <Pine.LNX.4.44L.0211192222300.4103-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jon Goldberg <jgoldberg@neocore.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 Nov 2002, Jon Goldberg wrote:

> 	We are currently at porting to Linux 2.4 kernel and I am having
> troubles finding information on VM.  Since the 2.4 Kernel support large
> amount of swap < 1TB and Physical Ram < 64GB.  Is there a way to get
> memory functions like mmap to use a 64 bit pointer instead of the 32bit
> pointer.  Since a memory mapped file the file is used as swap I should
> be able to have it map a file larger than 4GB and have the OS do the
> page management.

No, this is not possible because of fundamental reasons.

Every page of virtual address space (3 GB, or .75 million pages)
can point to exactly 1 page in the file. This means that you
cannot map more than 3 GB of file into a process and have the
kernel do "automatic switching", since the kernel has no way to
know which page the process wants to access.

The only way to work around that is to map/unmap by hand from
your process.

> Is there a way of doing this in i386 or i686 version of kernel or do I
> have run Linux on IA-64 or other 64-bit chips to do this?

If you really want to map in more than 3 GB at once, you will
need to use a 64-bit architecture.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".
http://www.surriel.com/		http://guru.conectiva.com/
Current spamtrap:  <a href=mailto:"october@surriel.com">october@surriel.com</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
