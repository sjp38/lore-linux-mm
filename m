Message-ID: <37F8DCD1.E726CBBC@switchboard.ericsson.se>
Date: Mon, 04 Oct 1999 18:58:57 +0200
From: Marcus Sundberg <erammsu@kieraypc01.p.y.ki.era.ericsson.se>
MIME-Version: 1.0
Subject: Re: MMIO regions
References: <Pine.LNX.4.10.9910041028350.7066-100000@imperial.edgeglobal.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

James Simmons wrote:
> 
> Howdy again!!
> 
>    I noticed something for SMP machines with all the dicussion about
> concurrent access to memory regions. What happens when you have two
> processes that have both mmapped the same MMIO region for some card.
> Doesn't have to be a video card,. On a SMP machine it is possible that
> both processes could access the same region at the same time. This could
> cause the card to go into a indeterminate state. Even lock the machine.
> Does their exist a way to handle this? Also some cards have mulitple MMIO
> regions. What if a process mmaps one MMIO region of this card and another
> process mmaps another MMIO region of this card. Now process one could
> alter the card in such a way it could effect the results that process two
> is expecting. How is this dealt with? Is it dealt with? If not what would
> be a good way to handle this?

AFAIK no drivers except fbcon drivers map any IO-region to userspace.

//Marcus
-- 
-------------------------------+------------------------------------
        Marcus Sundberg        | http://www.stacken.kth.se/~mackan/
 Royal Institute of Technology |       Phone: +46 707 295404
       Stockholm, Sweden       |   E-Mail: mackan@stacken.kth.se
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
