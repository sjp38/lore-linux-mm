Subject: Re: [PATCH][RFC] slub: increasing order reduces memory usage of
	some key caches
From: Richard Kennedy <richard@rsk.demon.co.uk>
In-Reply-To: <4880AEFE.3060909@linux-foundation.org>
References: <1216211371.3122.46.camel@castor.localdomain>
	 <487DF5D4.9070101@linux-foundation.org>
	 <1216216730.3122.60.camel@castor.localdomain>
	 <487DFFBE.5050407@linux-foundation.org>
	 <1216375025.3082.7.camel@castor.localdomain>
	 <4880A694.1000100@linux-foundation.org>
	 <1216392177.3082.27.camel@castor.localdomain>
	 <4880AEFE.3060909@linux-foundation.org>
Content-Type: text/plain
Date: Fri, 18 Jul 2008 16:22:40 +0100
Message-Id: <1216394560.3082.32.camel@castor.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: penberg@cs.helsinki.fi, mpm@selenic.com, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-07-18 at 09:55 -0500, Christoph Lameter wrote:
> OK that is now 4215 pages before and 4112 after the patch? Yawn.... So barely any effect?

Well it's not huge but there's another 100+ pages out of radix_tree,
too. & I've not inspected the rest of the cache usage.

I hope there's nowhere in the kernel wasting large amounts of memory --
that's what userspace is for ;) 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
