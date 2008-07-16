Message-ID: <487DFFBE.5050407@linux-foundation.org>
Date: Wed, 16 Jul 2008 09:03:42 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH][RFC] slub: increasing order reduces memory usage of	some
 key caches
References: <1216211371.3122.46.camel@castor.localdomain>	 <487DF5D4.9070101@linux-foundation.org> <1216216730.3122.60.camel@castor.localdomain>
In-Reply-To: <1216216730.3122.60.camel@castor.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: penberg@cs.helsinki.fi, mpm@selenic.com, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Richard Kennedy wrote:

> before
> dentry             82136  82137    208   19    1 : tunables    0    0    0 : slabdata   4323   4323      0
> after
> dentry             79482  79482    208   39    2 : tunables    0    0    0 : slabdata   2038   2038      0

19 objects with an order 1 alloc and 208 byte size? Urgh. 8192/208 = 39 and not 19.

Kmemcheck or something else active? We seem to be loosing 50% of our memory.

Pekka: Is the slabinfo emulation somehow broken?

I'd really like to see the output of slabinfo dentry.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
