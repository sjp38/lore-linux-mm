Date: Thu, 7 Sep 2000 16:26:15 +0200
From: Ralf Baechle <ralf@oss.sgi.com>
Subject: Re: pte_pagenr/MAP_NR deleted in pre6
Message-ID: <20000907162615.D6580@bacchus.dhis.org>
References: <200008171950.MAA45378@google.engr.sgi.com> <200008171941.MAA24042@pizda.ninka.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <200008171941.MAA24042@pizda.ninka.net>; from davem@redhat.com on Thu, Aug 17, 2000 at 12:41:52PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: kanoj@google.engr.sgi.com, alan@lxorguk.ukuu.org.uk, sct@redhat.com, roman@augan.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, rmk@arm.linux.org.uk, nico@cam.org, davidm@hpl.hp.com
List-ID: <linux-mm.kvack.org>

On Thu, Aug 17, 2000 at 12:41:52PM -0700, David S. Miller wrote:

> ISA is a dead hardware technology and therefore how it works is pretty
> much fixed in stone.
> 
> Perhaps some older MIPS machines supporting ISA could benefit from
> an API similar to the PCI dma stuff, as Alan mentioned.  But that is
> the only case which has any merit in my mind.

ISA isn't really a consideration for MIPS.  All that ISA hardware
couldn't be supported by treating it the same as on a x86 system.  That's
not top efficient but justified given the importance of ISA for MIPS
boxes - nearly NIL.

  Ralf
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
