Date: Wed, 16 Aug 2000 11:24:23 -0700
Message-Id: <200008161824.LAA09497@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <20000816192012.K19260@redhat.com> (sct@redhat.com)
Subject: Re: pte_pagenr/MAP_NR deleted in pre6
References: <399A4FE4.FA5C397A@augan.com> <200008161713.KAA54085@google.engr.sgi.com> <20000816192012.K19260@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sct@redhat.com
Cc: kanoj@google.engr.sgi.com, roman@augan.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, rmk@arm.linux.org.uk, nico@cam.org, davidm@hpl.hp.com, alan@lxorguk.ukuu.org.uk
List-ID: <linux-mm.kvack.org>

   Drivers which do DMA but only to <4GB addresses need bounce
   buffers.

This is only true in an architecture specific sense (ie. x86 systems
are the one's which have this particular restriction).

Which is one of the reasons I wish the bounce buffer stuff went into
the place it belongs, behind the pci_dma API.  If we move to a
page+offset model for drivers, we could do exactly this and also
handle cases like ix86 PAE.

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
