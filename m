Message-Id: <200009252003.NAA19840@icarus.com>
Subject: Re: the new VMt [4MB+ blocks] 
In-Reply-To: Message from Matti Aarnio <matti.aarnio@zmailer.org>
   of "Mon, 25 Sep 2000 22:03:01 +0300." <20000925220301.Z11669@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Date: Mon, 25 Sep 2000 13:02:59 -0700
From: Stephen Williams <steve@icarus.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matti Aarnio <matti.aarnio@zmailer.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

matti.aarnio@zmailer.org said:
> Sometimes allocating such monster memory blocks could be supported,
> 	but it should not be expected to be *fast*.  E.g. if doing it in
> 	"reliable" way needs possibly moving currently allocated pages
> 	away from memory to create such a hole(s), so be it.


matti.aarnio@zmailer.org said:
> Anybody here who can describe those M$ API calls ?
> 	Are they kernel/DDK-only, or userspace ones, or both ?

NT does indeed support allocating contiguous buffers of memory, which is
useful when the hardware in question doesn't do scatter-gather. I have
on occasion been compelled to use these routines. (Paradoxically, the
requirements in my case came from broken NT mmap support and not from the
hardware. Blech!)

Anyhow, these routines are indeed slow. And judging by the amount of disk
noise I hear when they are called, they do try to kick out pages to make
an allocation work. However, even so the M$ calls will eventually fail due
to lack of large enough holes, so fragmentation takes its toll.

So, they are both slow and unreliable under NT. But drivers that use them
tend to be loaded once at boot time, and that's it.
-- 
Steve Williams                "The woods are lovely, dark and deep.
steve@icarus.com              But I have promises to keep,
steve@picturel.com            and lines to code before I sleep,
http://www.picturel.com       And lines to code before I sleep."


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
