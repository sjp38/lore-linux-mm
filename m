Subject: Re: mmap and raw disk devices...
References: <3BCEFC46.9E8FEF7A@htec.demon.co.uk>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 19 Oct 2001 08:46:05 -0600
In-Reply-To: <3BCEFC46.9E8FEF7A@htec.demon.co.uk>
Message-ID: <m1ofn3ofgy.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christopher Quinn <cq@htec.demon.co.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christopher Quinn <cq@htec.demon.co.uk> writes:

> Hello list,
> 
> I tried to mmap a disk partition raw device which failed.
> Can anyone tell me the reason mmap does not support such a
> device? 
> I would have thought a mmap/raw-device combination to be ideal as
> a basis for a high performance database system.
>
> I know there is the option of managing memory<->disk movements
> oneself, but my understanding is that handling page-faults via
> signal trap handling is *very* expensive. Far better to leave
> such matters in the hands of the OS.
> 
> I suspect there is some fundamental reason for not mmap'ing raw
> devices that is patently obvious to everyone but me! 

mmap goes through the page cache.  It should work in 2.4.10+
though someone might not have enabled it.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
