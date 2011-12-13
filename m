Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 97AD56B0281
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 14:06:41 -0500 (EST)
Date: Tue, 13 Dec 2011 11:06:32 -0800
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [patch v3]numa: add a sysctl to control interleave allocation
 granularity from each node to improve I/O performance
Message-ID: <20111213190632.GA5830@tassilo.jf.intel.com>
References: <1323655125.22361.376.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1323655125.22361.376.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Christoph Lameter <cl@linux.com>, lee.schermerhorn@hp.com, David Rientjes <rientjes@google.com>

On Mon, Dec 12, 2011 at 09:58:45AM +0800, Shaohua Li wrote:
> If mem plicy is interleaves, we will allocated pages from nodes in a round
> robin way. This surely can do interleave fairly, but not optimal.
> 
> Say the pages will be used for I/O later. Interleave allocation for two pages
> are allocated from two nodes, so the pages are not physically continuous. Later

I would prefer to add a new policy (INTERLEAVE_MULTI or so) for this
instead of a global sysctl, that takes the additional parameter.

Also I don't like having more per task state. Could you compute this
from the address instead even for the process policy case?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
