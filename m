Date: Mon, 25 Sep 2000 18:04:48 +0200
From: "Andi Kleen" <ak@suse.de>
Subject: Re: the new VMt
Message-ID: <20000925180448.A25083@gruyere.muc.suse.de>
References: <20000925174138.D25814@athlon.random> <Pine.LNX.4.21.0009251747190.9122-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0009251747190.9122-100000@elte.hu>; from mingo@elte.hu on Mon, Sep 25, 2000 at 06:02:18PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrea Arcangeli <andrea@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 06:02:18PM +0200, Ingo Molnar wrote:
> Frankly, how often do we allocate multi-order pages? I've just made quick
> statistics wrt. how allocation orders are distributed on a more or less
> typical system:
> 
> 	(ALLOC ORDER)
> 	0: 167081
> 	1: 850
> 	2: 16
> 	3: 25
> 	4: 0
> 	5: 1
> 	6: 0
> 	7: 2
> 	8: 13
> 	9: 5
> 
> ie. 99.45% of all allocations are single-page! 0.50% is the 8kb
> task-structure. The rest is 0.05%.

An important exception in 2.2/2.4 is NFS with bigger rsize (will be fixed
in 2.5, but 2.4 does it this way). For an 8K r/wsize you need reliable 
(=GFP_ATOMIC) 16K allocations.  

Another thing I would worry about are ports with multiple user page sizes in 2.5.
Another ugly case is the x86-64 port which has 4K pages but may likely need
a 16K kernel stack due to the 64bit stack bloat.


-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
