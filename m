Date: Fri, 16 Mar 2001 12:49:59 +0100
From: Francois Romieu <romieu@cogenit.fr>
Subject: Re: Non PCI bursting cards should go to the trash can
Message-ID: <20010316124959.A407@se1.cogenit.fr>
References: <20010315062806.24508.qmail@nwcst340.netaddress.usa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20010315062806.24508.qmail@nwcst340.netaddress.usa.net>; from qureshi_jawad@usa.net on Wed, Mar 14, 2001 at 11:28:06PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jawad Qureshi <qureshi_jawad@usa.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jawad Qureshi <qureshi_jawad@usa.net> ecrit :
[...]
> I am facing some problems with the pci. I have two questions about Pci.
> First is that 
> 1-how one can explicitly specify to brust on the pci device;
> 2-We have a custom made pci card . The problem is that the transfer on this
> card is slow. I am making 40 double word transfers from the fifoes on the
> board to the memory. The pci card does not allow brusts. These transfers are
> taking almost 32us. Can any body tell why this much time is taking place.

32us/40 = 800ns. PCI at 33MHz, cycle = 33ns -> 24 cycle/access.
The *address* phase of a PCI r/w cycle eats 6 cycles for himself at least.
It looks rather normal.

-- 
Ueimor
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
