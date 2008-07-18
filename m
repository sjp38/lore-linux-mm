Subject: Re: [PATCH][RFC] slub: increasing order reduces memory usage
	of	some key caches
From: Richard Kennedy <richard@rsk.demon.co.uk>
In-Reply-To: <487F79B8.9050104@linux-foundation.org>
References: <1216211371.3122.46.camel@castor.localdomain>
	 <487E1ACF.3030603@linux-foundation.org>
	 <1216289348.3061.16.camel@castor.localdomain>
	 <487F79B8.9050104@linux-foundation.org>
Content-Type: text/plain
Date: Fri, 18 Jul 2008 11:17:39 +0100
Message-Id: <1216376259.3082.22.camel@castor.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: penberg@cs.helsinki.fi, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-07-17 at 11:56 -0500, Christoph Lameter wrote:
> Richard Kennedy wrote:
> 
> > Thanks, I'll give that a try.
> > 
> > Do we need to limit the number of times this applies though?
> 
> Well so far I am not sure that it is useful to tune caches based on a
> waste calculation that is object size based. We know that larger page
> sizes are beneficial for performance so the results are not that
> surprising.
> 
> We could rethink the automatic slab size configuration. Maybe add a
> memory size based component? If we have more than 512M then double
> slub_min_objects?

That should help :)  

I just wonder if it's too simple though? There's such a wide range of
hardware configurations & workloads it could be difficult to pick a
one-size-fits-all solution.

I wonder if something more dynamic is needed ?

Slub is already smart enough to handle variable order slabs, so could it
pick the order based on the rate of growth of a cache & the free memory
available?
But tuning such an algorithm might be fun! ;)

Richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
