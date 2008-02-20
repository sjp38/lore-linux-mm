Date: Wed, 20 Feb 2008 19:51:04 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] Document huge memory/cache overhead of memory
	controller in Kconfig
Message-ID: <20080220185104.GA30416@elf.ucw.cz>
References: <20080220122338.GA4352@basil.nowhere.org> <47BC2275.4060900@linux.vnet.ibm.com> <18364.16552.455371.242369@stoffel.org> <47BC4554.10304@linux.vnet.ibm.com> <Pine.LNX.4.64.0802201647060.26109@fbirervta.pbzchgretzou.qr> <20080220181911.GA4760@ucw.cz> <Pine.LNX.4.64.0802201927440.26109@fbirervta.pbzchgretzou.qr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802201927440.26109@fbirervta.pbzchgretzou.qr>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Engelhardt <jengelh@computergmbh.de>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, John Stoffel <john@stoffel.org>, Andi Kleen <andi@firstfloor.org>, akpm@osdl.org, torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 2008-02-20 19:28:03, Jan Engelhardt wrote:
> 
> On Feb 20 2008 18:19, Pavel Machek wrote:
> >> 
> >> For ordinary desktop people, memory controller is what developers
> >> know as MMU or sometimes even some other mysterious piece of silicon
> >> inside the heavy box.
> >
> >Actually I'd guess 'memory controller' == 'DRAM controller' == part of
> >northbridge that talks to DRAM.
> 
> Yeah that must have been it when Windows says it found a new controller
> after changing the mainboard underneath.

Just for fun... this option really has to be renamed:

Memory controller
~~~~~~~~~~~~~~~~~
>From Wikipedia, the free encyclopedia

The memory controller is a chip on a computer's motherboard or CPU die
which manages the flow of data going to and from the memory.

Most computers based on an Intel processor have a memory controller
implemented on their motherboard's north bridge, though some modern
microprocessors, such as AMD's Athlon 64 and Opteron processors, IBM's
POWER5, and Sun Microsystems UltraSPARC T1 have a memory controller on
the CPU die to reduce the memory latency. 

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
