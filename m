Message-ID: <4880A6F0.6020501@linux-foundation.org>
Date: Fri, 18 Jul 2008 09:21:36 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH][RFC] slub: increasing order reduces memory usage	of	some
 key caches
References: <1216211371.3122.46.camel@castor.localdomain>	 <487E1ACF.3030603@linux-foundation.org>	 <1216289348.3061.16.camel@castor.localdomain>	 <487F79B8.9050104@linux-foundation.org> <1216376259.3082.22.camel@castor.localdomain>
In-Reply-To: <1216376259.3082.22.camel@castor.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: penberg@cs.helsinki.fi, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Richard Kennedy wrote:

>> We could rethink the automatic slab size configuration. Maybe add a
>> memory size based component? If we have more than 512M then double
>> slub_min_objects?
> 
> That should help :)  
> 
> I just wonder if it's too simple though? There's such a wide range of
> hardware configurations & workloads it could be difficult to pick a
> one-size-fits-all solution.
> 
> I wonder if something more dynamic is needed ?

If you have the time to work on it then go ahead.

> Slub is already smart enough to handle variable order slabs, so could it
> pick the order based on the rate of growth of a cache & the free memory
> available?
> But tuning such an algorithm might be fun! ;)

Sure it could do that. We just need a smart person that has fun tuning such an algorithm until its mature for upstream inclusion.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
