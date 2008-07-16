Received: by el-out-1112.google.com with SMTP id y26so1419533ele.26
        for <linux-mm@kvack.org>; Wed, 16 Jul 2008 07:33:54 -0700 (PDT)
Message-ID: <19f34abd0807160733q2594bd9fk268703d2aedc8254@mail.gmail.com>
Date: Wed, 16 Jul 2008 16:33:53 +0200
From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: [PATCH][RFC] slub: increasing order reduces memory usage of some key caches
In-Reply-To: <487DFFBE.5050407@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1216211371.3122.46.camel@castor.localdomain>
	 <487DF5D4.9070101@linux-foundation.org>
	 <1216216730.3122.60.camel@castor.localdomain>
	 <487DFFBE.5050407@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Richard Kennedy <richard@rsk.demon.co.uk>, penberg@cs.helsinki.fi, mpm@selenic.com, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 16, 2008 at 4:03 PM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> Richard Kennedy wrote:
>
>> before
>> dentry             82136  82137    208   19    1 : tunables    0    0    0 : slabdata   4323   4323      0
>> after
>> dentry             79482  79482    208   39    2 : tunables    0    0    0 : slabdata   2038   2038      0
>
> 19 objects with an order 1 alloc and 208 byte size? Urgh. 8192/208 = 39 and not 19.
>
> Kmemcheck or something else active? We seem to be loosing 50% of our memory.

Hm, I don't think so? I thought that those 1 and 2 were not orders,
but in fact the number of pages. Which seems correct, since now you
have 4096 / 208 = 19 :-)

(His patch bumps order from 0 to 1, so the number of pages were bumped
from 1 to 2.)

Or..?


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
