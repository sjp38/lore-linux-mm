Date: Thu, 17 Aug 2000 12:01:49 -0700
Message-Id: <200008171901.MAA23835@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <200008171907.MAA37675@google.engr.sgi.com> (message from Kanoj
	Sarcar on Thu, 17 Aug 2000 12:07:12 -0700 (PDT))
Subject: Re: pte_pagenr/MAP_NR deleted in pre6
References: <200008171907.MAA37675@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kanoj@google.engr.sgi.com
Cc: sct@redhat.comsct@redhat.com, roman@augan.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, rmk@arm.linux.org.uk, nico@cam.org, davidm@hpl.hp.com, alan@lxorguk.ukuu.org.uk
List-ID: <linux-mm.kvack.org>

   Whatever you do, you either have to introduce paddr_t (which to me
   seems more intuitive) or page_to_pfn. We can argue one way or
   another, but paddr_t might give you type checking for free too ...

My only two gripes about paddr_t is that long long is not only
expensive but has been also known to be buggy on 32-bit platforms.

The next gripe is that it will make many clueless driver
etc. developers (who don't read documentation even, but write a large
portion of the vendor Linux drivers :-) will try to do things
like "void *p = (void *) (PAGE_OFFSET + x->paddr);" and expect
this to work, or maybe they'll even pass it to virt_to_bus or similar.

If people don't think these two things will be an issue, fine with
me. :-)

Which reminds me, we need to schedule a field day early 2.5.x where
virt_to_bus and bus_to_virt are exterminated, this is the only way we
can move to drivers using page+offset correctly, forcing them through
interface such as the pci_dma API instead.

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
