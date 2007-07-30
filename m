Date: Mon, 30 Jul 2007 03:18:42 +0100 (BST)
From: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Subject: [SPARC32] NULL pointer derefference
Message-ID: <Pine.LNX.4.61.0707300301340.32210@mtfhpc.demon.co.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ollie Wild <aaw@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-arch@vger.kernel.org, sparclinux@vger.kernel.org, wli@holomorphy.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

Hi All,

Unfortunatly Sparc32 sun4c low level memory management apears to be 
incompatible with commit b6a2fea39318e43fee84fa7b0b90d68bed92d2ba
mm: variable length argument support.

For some reason, this commit corrupts the memory used by the low level 
context/pte handling ring buffers in arch/sparc/mm/sun4c (in 
add_ring_ordered, head->next becomes set to a NULL pointer).

I had a quick look at http://www.linux-mm.org to see if there were any 
diagrams that show what is going on in the memory management systems, to 
see if there was something that I could use to help me work out what is 
going on, but I could not see any.

Can any one help?

Regards
 	Mark Fortescue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
