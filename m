Message-ID: <A91A08D00A4FD2119BD500104B55BDF6021A67A2@pdbh936a.pdb.siemens.de>
From: "Wichert, Gerhard" <Gerhard.Wichert@pdb.siemens.de>
Subject: AW: [bigmem-patch] 4GB with Linux on IA32
Date: Thu, 19 Aug 1999 16:01:52 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thierry Vignaud <tvignaud@mandrakesoft.com>, Andrea Arcangeli <andrea@suse.de>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, torvalds@transmeta.com, sct@redhat.com, "Wichert, Gerhard" <Gerhard.Wichert@pdb.siemens.de>, "Gerhard, Winfried" <Winfried.Gerhard@pdb.siemens.de>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


> -----Ursprungliche Nachricht-----
> Von: Thierry Vignaud [mailto:tvignaud@mandrakesoft.com]
> Gesendet am: Donnerstag, 19. August 1999 15:34
> An: Andrea Arcangeli
> Cc: Alan Cox; Kanoj Sarcar; torvalds@transmeta.com; sct@redhat.com;
> Gerhard.Wichert@pdb.siemens.de; Winfried.Gerhard@pdb.siemens.de;
> linux-kernel@vger.rutgers.edu; linux-mm@kvack.org
> Betreff: Re: [bigmem-patch] 4GB with Linux on IA32
> 
> Andrea Arcangeli wrote:
> > 
> > I uploaded a new bigmem-2.3.13-M patch here:
> > 
> >         
> ftp://e-mind.com/pub/andrea/kernel-patches/2.3.13/bigmem-2.3.13-M
> > 
> > (the raw-io must be avoided with bigmem enabled, since the 
> protection I
> > added in get_page_map() doesn't work right now)
> > 
> > If you'll avoid to do raw-io the patch should be safe and 
> ready to use.
> 
> since only recent motherboard support more than 512Mb RAM, and since
> they used i686 (PPro, P2, P3), why not use the pse36 
> extension of these
> cpu that enable to stock the segment length on 24bits, which give 64To
> when mem unit is 4b page.
> this'll make the limit much higher (say 128Mb RAM for the kernel space
> memory and 15,9To for the user space).

With pse36 only your physical address space will grow. Your virtual address
space is still limited to 4GB.

Gerhard
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
