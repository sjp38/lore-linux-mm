Date: Thu, 20 Apr 2000 11:20:12 +0200 (CEST)
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: questions on having a driver pin user memory for DMA
In-Reply-To: <m1g0shi8cm.fsf@flinx.biederman.org>
Message-ID: <Pine.LNX.4.10.10004201115350.16896-100000@nightmaster.csn.tu-chemnitz.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Weimin Tchen <wtchen@giganet.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 20 Apr 2000, Eric W. Biederman wrote:

> Your interface sounds like it walks around all of the networking
> code in the kernel.  How can that be good?

It is not a NIC in the sense that you do TCP/IP over it. These
NICs with VIA support are used in high speed homogenous networks
between cluster nodes IIRC.

So it _is_ ok to work around all this networking code, because
they do DSHM and message passing with these networks in a very
homogenous manner.

Right Weimin?

Regards

Ingo Oeser
-- 
Feel the power of the penguin - run linux@your.pc
<esc>:x

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
