Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 7CB756B0267
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 15:39:06 -0500 (EST)
Date: Tue, 13 Dec 2011 12:38:56 -0800
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [patch v3]numa: add a sysctl to control interleave allocation
 granularity from each node to improve I/O performance
Message-ID: <20111213203856.GA6312@tassilo.jf.intel.com>
References: <1323655125.22361.376.camel@sli10-conroe>
 <20111213190632.GA5830@tassilo.jf.intel.com>
 <alpine.DEB.2.00.1112131412320.27186@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1112131412320.27186@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Shaohua Li <shaohua.li@intel.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, lee.schermerhorn@hp.com, David Rientjes <rientjes@google.com>

On Tue, Dec 13, 2011 at 02:12:58PM -0600, Christoph Lameter wrote:
> On Tue, 13 Dec 2011, Andi Kleen wrote:
> 
> > I would prefer to add a new policy (INTERLEAVE_MULTI or so) for this
> > instead of a global sysctl, that takes the additional parameter.
> 
> That would require a change of all scripts and code that uses
> MPOL_INTERLEAVE. Lets not do that.

Yes, but setting a sysctl would need the same right?

It's not clear that all workloads want this.

With a global switch only you cannot set it case by case.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
