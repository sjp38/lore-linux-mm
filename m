Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id EA7C06B0306
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 12:53:04 -0500 (EST)
Date: Wed, 14 Dec 2011 09:53:02 -0800
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [patch v3]numa: add a sysctl to control interleave allocation
 granularity from each node to improve I/O performance
Message-ID: <20111214175302.GA2600@alboin.jf.intel.com>
References: <1323655125.22361.376.camel@sli10-conroe>
 <20111213190632.GA5830@tassilo.jf.intel.com>
 <alpine.DEB.2.00.1112131412320.27186@router.home>
 <20111213203856.GA6312@tassilo.jf.intel.com>
 <1323830027.22361.401.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1323830027.22361.401.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Christoph Lameter <cl@linux.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, "lee.schermerhorn@hp.com" <lee.schermerhorn@hp.com>, David Rientjes <rientjes@google.com>

> That's what I want to avoid letting each apps to explicitly do it, it's
> a lot of burden.

Usually apps that set NUMA policy can change it. Most don't anyways.
If it's just a script with numactl it's easily changed.

> That's true only workload with heavy I/O wants this. but I don't expect
> it will harm other workloads.

How do you know? 

> 
> >> Also I don't like having more per task state. Could you compute this
> >> from the address instead even for the process policy case?
> >
> >That sounds good.
> the process policy case doesn't give an address for allocation.

That's true.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
