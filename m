Date: Mon, 16 Aug 1999 22:54:45 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
In-Reply-To: <E11GSfS-0003ua-00@the-village.bc.nu>
Message-ID: <Pine.LNX.4.10.9908162235570.4139-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, torvalds@transmeta.com, sct@redhat.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Aug 1999, Alan Cox wrote:

>> a range of user pages that were in bigmem area? Also, debuggers
>> want to look at user memory, so they would also need to map the
>> pages. Are there any other cases where a driver might want to 
>
>That is the tricky one. What occurs if I mmap a high memory page of
>another process via /proc/pid/mem ? then write it

IMO Kanoj was talking about another thing (ptrace).

About the /proc/pid/mem I noticed there are two kmap missing in mem_write
and mem_read (so to read and write from /proc/pid/mem).

The mmap over a /proc/pid/mem instead seems just fine. The only thing you
must care is when you write to the page _inside_ the kernel, if you touch
pages from userspace you'll be fine as usual. For userspace bigmem pages
are completly equal to regular pages and no kernel change is necessary in
such user-map places like mem_mmap in fs/proc/mem.c.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
