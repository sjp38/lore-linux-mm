Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA25146
	for <linux-mm@kvack.org>; Tue, 24 Mar 1998 19:12:20 -0500
Date: Tue, 24 Mar 1998 16:11:56 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Lazy page reclamation on SMP machines: memory barriers
In-Reply-To: <199803242254.WAA03274@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.95.980324161015.5682I-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: linux-mm@kvack.org, linux-smp@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>



On Tue, 24 Mar 1998, Stephen C. Tweedie wrote:
> > Intel guarantees total ordering around any locked instruction, so the
> > spinlocks themselves act as the barriers. 
> 
> Fine.  Can we assume that spinlocks and atomic set/clear_bit
> instructions have the same semantics on other CPUs?

We can certainly guarantee that a spinlock has the necessary locking
semantics - anything else would make spinlocks useless. 

The other atomic instructions I'd be inclined to claim to be weakly
ordered.

		Linus
