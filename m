Subject: Re: [PATCH][RFC] slub: increasing order reduces memory usage
	of	some key caches
From: Richard Kennedy <richard@rsk.demon.co.uk>
In-Reply-To: <487DFFBE.5050407@linux-foundation.org>
References: <1216211371.3122.46.camel@castor.localdomain>
	 <487DF5D4.9070101@linux-foundation.org>
	 <1216216730.3122.60.camel@castor.localdomain>
	 <487DFFBE.5050407@linux-foundation.org>
Content-Type: text/plain
Date: Wed, 16 Jul 2008 15:30:57 +0100
Message-Id: <1216218657.3122.66.camel@castor.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: penberg@cs.helsinki.fi, mpm@selenic.com, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-07-16 at 09:03 -0500, Christoph Lameter wrote:
> Richard Kennedy wrote:
> 
> > before
> > dentry             82136  82137    208   19    1 : tunables    0    0    0 : slabdata   4323   4323      0
> > after
> > dentry             79482  79482    208   39    2 : tunables    0    0    0 : slabdata   2038   2038      0
> 
> 19 objects with an order 1 alloc and 208 byte size? Urgh. 8192/208 = 39 and not 19.
> 
> Kmemcheck or something else active? We seem to be loosing 50% of our memory.
> 
> Pekka: Is the slabinfo emulation somehow broken?
> 
> I'd really like to see the output of slabinfo dentry.
> 
/proc/slabinfo says it shows pages/slab not order -- so the numbers are consistent if nothing else.

I'm getting the log message 
> SLUB: increasing order dentry->[1] [208]
from my code, so it looks correct. It's just the standard code is
picking order 0.

I'm just rebuilding the kernel & will get you that slabinfo

Richard 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
