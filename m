Message-ID: <487F79B8.9050104@linux-foundation.org>
Date: Thu, 17 Jul 2008 11:56:24 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH][RFC] slub: increasing order reduces memory usage of	some
 key caches
References: <1216211371.3122.46.camel@castor.localdomain>	 <487E1ACF.3030603@linux-foundation.org> <1216289348.3061.16.camel@castor.localdomain>
In-Reply-To: <1216289348.3061.16.camel@castor.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: penberg@cs.helsinki.fi, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Richard Kennedy wrote:

> Thanks, I'll give that a try.
> 
> Do we need to limit the number of times this applies though?

Well so far I am not sure that it is useful to tune caches based on a waste calculation that is object size based. We know that larger page sizes are beneficial for performance so the results are not that surprising.

We could rethink the automatic slab size configuration. Maybe add a memory size based component? If we have more than 512M then double slub_min_objects?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
