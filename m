Subject: Re: [bigmem-patch] 4GB with Linux on IA32
Date: Fri, 20 Aug 1999 10:55:38 +0100 (BST)
In-Reply-To: <37BD0559.99C5E320@mandrakesoft.com> from "Thierry Vignaud" at Aug 20, 99 07:35:53 am
Content-Type: text
Message-Id: <E11HlOe-0007cg-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thierry Vignaud <tvignaud@mandrakesoft.com>
Cc: sct@redhat.com, andrea@suse.de, alan@lxorguk.ukuu.org.uk, kanoj@google.engr.sgi.com, torvalds@transmeta.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, x-linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Yes, but we do can use 24:32 referencse (as
> pse36_extended_selectors:offset). Each process may own a ldt that allow
> him to own several 4Gb segment : code, data, stack, kernel mem mapped,
> librairies, shared mem (X11/dga -> fb mem and IPC shm).

32bit large mode. 

> We may have to hack gcc & binutils so they generate references against
> new selectors. We may put the kernel mem region that the process see in

Thats probably four years work. You also need to do a large mode glibc port
so budget another year. And maybe a couple of man years for the kernel.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
