Date: Mon, 16 Aug 1999 23:41:50 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
In-Reply-To: <199908170637.XAA81444@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.9908162339360.1048-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Andrea Arcangeli <andrea@suse.de>, alan@lxorguk.ukuu.org.uk, sct@redhat.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 16 Aug 1999, Kanoj Sarcar wrote:
> 
> As I pointed out before, I don't think rawio is the only case which
> breaks.
> 
> I will give you one example of the type of cases that I am talking about.
> In drivers/char/bttv.c, VIDIOCSFBUF ioctl seems to be setting the "vidadr"
> to a kernel virtual address from the physical address present in the 
> user's pte. This will not work for bigmem pages.

This is exactly why I have always been adamant that people should NOT do
direct IO and try to walk the page tables. But people have ignored me, and
quite frankly, those drivers should just be broken. The painful part is
finding out which of them do it, but once done they should just be broken
wrt bigmem, no questions asked.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
