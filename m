From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199908170637.XAA81444@google.engr.sgi.com>
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
Date: Mon, 16 Aug 1999 23:37:20 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.10.9908170151190.14379-100000@laser.random> from "Andrea Arcangeli" at Aug 17, 99 02:10:43 am
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: alan@lxorguk.ukuu.org.uk, torvalds@transmeta.com, sct@redhat.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> >way it is, is so that drivers don't break. I think 2.3 is the place to 
> >teach the kernel and drivers that all of memory is not directly mappable.
> 
> I tried to avoid this (and I am been successfully until I noticed raw-io
> in 2.3.13... sigh).
> 
> In the meantime I'll take raw-io disabled if CONFIG_BIGMEM is set .
>

Andrea,

As I pointed out before, I don't think rawio is the only case which
breaks.

I will give you one example of the type of cases that I am talking about.
In drivers/char/bttv.c, VIDIOCSFBUF ioctl seems to be setting the "vidadr"
to a kernel virtual address from the physical address present in the 
user's pte. This will not work for bigmem pages.

Now, you might claim that this driver is never used on ia32, or analyze
the way "vidadr" is used and show that the kernel never access the 
kernel v/a stored in "vidadr". What I am pointing out is that this kind
of analysis needs to be made for all drivers (that uses macros that are
dependent on PAGE_OFFSET) ... unless you can claim that you have already 
done this analysis ...

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
