Subject: Re: 2.5.67-mm2
From: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
In-Reply-To: <200304130317.h3D3HprZ021939@turing-police.cc.vt.edu>
References: <20030412180852.77b6c5e8.akpm@digeo.com>
	 <1050198928.597.6.camel@teapot.felipe-alfaro.com>
	 <200304130317.h3D3HprZ021939@turing-police.cc.vt.edu>
Content-Type: text/plain
Message-Id: <1050232513.593.2.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Date: 13 Apr 2003 13:15:13 +0200
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Andrew Morton <akpm@digeo.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 2003-04-13 at 05:17, Valdis.Kletnieks@vt.edu wrote:
> On Sun, 13 Apr 2003 03:55:29 +0200, Felipe Alfaro Solana said:
> 
> > Any patches for CardBus/PCMCIA support? It's broken for me since
> > 2.5.66-mm2 (it works with 2.5.66-mm1) probably due to PCI changes or the
> > new PCMCIA state machine: if I boot my machine with my 3Com CardBus NIC
> > plugged in, the kernel deadlocks while checking the sockets, but it
> > works when booting with the card unplugged, and then plugging it back
> > once the system is stable (for example, init 1).
> 
> Also seeing this with a Xircom card under vanilla 2.5.67.
> 
> lspci reports this card as:
> 
> 03:00.0 Ethernet controller: Xircom Cardbus Ethernet 10/100 (rev 03)
> 03:00.1 Serial controller: Xircom Cardbus Ethernet + 56k Modem (rev 03)
> 
> Russel King posted an analysis back on April 1, which indicated he knew
> about the problem, understood it, and was working on it.

Yeah! I know, but I wrote him and didn't get a response, so I'm a little
bit worried. I assume he'll be too busy.

-- 
Please AVOID sending me WORD, EXCEL or POWERPOINT attachments.
See http://www.fsf.org/philosophy/no-word-attachments.html
Linux Registered User #287198

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
