Date: Thu, 9 Aug 2001 12:50:33 +0200
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: Swapping for diskless nodes
Message-ID: <20010809125033.E1200@nightmaster.csn.tu-chemnitz.de>
References: <no.id> <E15Ulnx-0006zZ-00@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E15Ulnx-0006zZ-00@the-village.bc.nu>; from alan@lxorguk.ukuu.org.uk on Thu, Aug 09, 2001 at 10:08:37AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 09, 2001 at 10:08:37AM +0100, Alan Cox wrote:
> > what is the best/recommended way to do remote swapping via the network
> > for diskless workstations or compute nodes in clusters in Linux 2.4?=20
> > Last time i checked was linux 2.2, and there were some races related=20
> > to network swapping back then. Has this been fixed for 2.4?
> 
> The best answer probably is "don't". Networks are high latency things for
> paging and paging is latency sensitive. If performance is not an issue then
> the nbd driver ought to work. You may need to check it uses the right
> GFP_ levels to avoid deadlocks and you might need to up the amount of atomic
> pool memory. Hopefully other hacks arent needed

While we are on it: I have an old machine with 64MB of RAM and a
new, fast machine with 1GB of RAM. 

Sometimes I need more RAM on the old one and asked myself,
whether I could first swap over network to the other one, into
its tmpfs, before digging into real swap on a hard disk.

I have only three machines attached to this small internal
100Mbit LAN.

Both machines use Kernel 2.4.x.

Are there any races I have to consider?

Thanks & Regards

Ingo Oeser
-- 
In der Wunschphantasie vieler Mann-Typen [ist die Frau] unsigned und
operatorvertraeglich. --- Dietz Proepper in dasr
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
