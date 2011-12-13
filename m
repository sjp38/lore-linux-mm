Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 15CEE6B0286
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 15:13:02 -0500 (EST)
Date: Tue, 13 Dec 2011 14:12:58 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch v3]numa: add a sysctl to control interleave allocation
 granularity from each node to improve I/O performance
In-Reply-To: <20111213190632.GA5830@tassilo.jf.intel.com>
Message-ID: <alpine.DEB.2.00.1112131412320.27186@router.home>
References: <1323655125.22361.376.camel@sli10-conroe> <20111213190632.GA5830@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Shaohua Li <shaohua.li@intel.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, lee.schermerhorn@hp.com, David Rientjes <rientjes@google.com>

On Tue, 13 Dec 2011, Andi Kleen wrote:

> I would prefer to add a new policy (INTERLEAVE_MULTI or so) for this
> instead of a global sysctl, that takes the additional parameter.

That would require a change of all scripts and code that uses
MPOL_INTERLEAVE. Lets not do that.

> Also I don't like having more per task state. Could you compute this
> from the address instead even for the process policy case?

That sounds good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
