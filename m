Message-ID: <487E09DB.3000205@linux-foundation.org>
Date: Wed, 16 Jul 2008 09:46:51 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH][RFC] slub: increasing order reduces memory usage of some
 key caches
References: <1216211371.3122.46.camel@castor.localdomain>	 <487DF5D4.9070101@linux-foundation.org>	 <1216216730.3122.60.camel@castor.localdomain>	 <487DFFBE.5050407@linux-foundation.org> <19f34abd0807160733q2594bd9fk268703d2aedc8254@mail.gmail.com>
In-Reply-To: <19f34abd0807160733q2594bd9fk268703d2aedc8254@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vegard Nossum <vegard.nossum@gmail.com>
Cc: Richard Kennedy <richard@rsk.demon.co.uk>, penberg@cs.helsinki.fi, mpm@selenic.com, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Vegard Nossum wrote:

> Hm, I don't think so? I thought that those 1 and 2 were not orders,
> but in fact the number of pages. Which seems correct, since now you
> have 4096 / 208 = 19 :-)

Makes sense. So the problem is that for some reason his kernel chose order 0 for dentries. Mine choose order 1 and everything was fine. Maybe related to the number of processors (my box has 8)? We added some logic in 2.6.26 to increase slab sizes if lots of processors are present.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
