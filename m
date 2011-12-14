Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 4A5716B02A7
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 21:21:21 -0500 (EST)
Subject: Re: [patch v3]numa: add a sysctl to control interleave allocation
 granularity from each node to improve I/O performance
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20111213203856.GA6312@tassilo.jf.intel.com>
References: <1323655125.22361.376.camel@sli10-conroe>
	 <20111213190632.GA5830@tassilo.jf.intel.com>
	 <alpine.DEB.2.00.1112131412320.27186@router.home>
	 <20111213203856.GA6312@tassilo.jf.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 14 Dec 2011 10:33:47 +0800
Message-ID: <1323830027.22361.401.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Christoph Lameter <cl@linux.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, "lee.schermerhorn@hp.com" <lee.schermerhorn@hp.com>, David Rientjes <rientjes@google.com>

On Wed, 2011-12-14 at 04:38 +0800, Andi Kleen wrote:
> On Tue, Dec 13, 2011 at 02:12:58PM -0600, Christoph Lameter wrote:
> > On Tue, 13 Dec 2011, Andi Kleen wrote:
> > 
> > > I would prefer to add a new policy (INTERLEAVE_MULTI or so) for this
> > > instead of a global sysctl, that takes the additional parameter.
> > 
> > That would require a change of all scripts and code that uses
> > MPOL_INTERLEAVE. Lets not do that.
> 
> Yes, but setting a sysctl would need the same right?
> 
> It's not clear that all workloads want this.
> 
> With a global switch only you cannot set it case by case.
That's what I want to avoid letting each apps to explicitly do it, it's
a lot of burden.
That's true only workload with heavy I/O wants this. but I don't expect
it will harm other workloads.

>> Also I don't like having more per task state. Could you compute this
>> from the address instead even for the process policy case?
>
>That sounds good.
the process policy case doesn't give an address for allocation.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
