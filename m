Subject: Re: [bigmem-patch] 4GB with Linux on IA32
Date: Tue, 17 Aug 1999 12:46:35 +0100 (BST)
In-Reply-To: <199908170650.XAA95856@google.engr.sgi.com> from "Kanoj Sarcar" at Aug 16, 99 11:50:42 pm
Content-Type: text
Message-Id: <E11GhhN-0004Rx-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: torvalds@transmeta.com, andrea@suse.de, alan@lxorguk.ukuu.org.uk, sct@redhat.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I will give you one example of the type of cases that I am talking about.
> In drivers/char/bttv.c, VIDIOCSFBUF ioctl seems to be setting the "vidadr"
> to a kernel virtual address from the physical address present in the 
> user's pte. This will not work for bigmem pages.

Oh now I understand Linus rather bizarre message

VIDIOCSFBUF takes a physical base address. The &1 stuff thats i nthere is 
a debug hook that never got taken out. You can ignore the &1 case in that
ioctl or just remove it.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
