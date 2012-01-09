Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id F03AB6B0068
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 02:16:52 -0500 (EST)
Subject: Re: [patch v3]numa: add a sysctl to control interleave allocation
 granularity from each node to improve I/O performance
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <1323912471.22361.431.camel@sli10-conroe>
References: <1323655125.22361.376.camel@sli10-conroe>
	 <20111213190632.GA5830@tassilo.jf.intel.com>
	 <alpine.DEB.2.00.1112131412320.27186@router.home>
	 <20111213203856.GA6312@tassilo.jf.intel.com>
	 <1323830027.22361.401.camel@sli10-conroe>
	 <20111214175302.GA2600@alboin.jf.intel.com>
	 <1323912471.22361.431.camel@sli10-conroe>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 09 Jan 2012 15:31:52 +0800
Message-ID: <1326094312.22361.557.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Christoph Lameter <cl@linux.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, "lee.schermerhorn@hp.com" <lee.schermerhorn@hp.com>, David Rientjes <rientjes@google.com>

On Thu, 2011-12-15 at 09:27 +0800, Shaohua Li wrote:
> On Thu, 2011-12-15 at 01:53 +0800, Andi Kleen wrote:
> > > That's what I want to avoid letting each apps to explicitly do it, it's
> > > a lot of burden.
> > 
> > Usually apps that set NUMA policy can change it. Most don't anyways.
> > If it's just a script with numactl it's easily changed.
> Hmm, why should apps set different granularity? the granularity change
> is to speed up I/O, which should have the same value for all apps.
> 
> > > That's true only workload with heavy I/O wants this. but I don't expect
> > > it will harm other workloads.
> > 
> > How do you know?
> I can't imagine how it could harm. Some arches can use big pages, big
> granularity should already been tested for years.
ping ...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
