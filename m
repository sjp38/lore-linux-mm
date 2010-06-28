Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C5CF66B01B2
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 14:55:09 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id o5SIt4Ft022827
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 11:55:05 -0700
Received: from pvg7 (pvg7.prod.google.com [10.241.210.135])
	by wpaz1.hot.corp.google.com with ESMTP id o5SIt2hU001784
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 11:55:03 -0700
Received: by pvg7 with SMTP id 7so619636pvg.10
        for <linux-mm@kvack.org>; Mon, 28 Jun 2010 11:55:02 -0700 (PDT)
Date: Mon, 28 Jun 2010 11:54:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q 00/16] SLUB with Queueing beats SLAB in hackbench
In-Reply-To: <AANLkTimQr0iNLr4uwZwx8F9jasIsi1yoyIR8r6etMtW8@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1006281152250.25490@chino.kir.corp.google.com>
References: <20100625212026.810557229@quilx.com> <20100626022441.GC29809@laptop> <AANLkTinOsPXdFc36mVDva-x0a0--gdFJuvWFQARwvx6y@mail.gmail.com> <alpine.DEB.2.00.1006280510370.8725@router.home> <AANLkTimQr0iNLr4uwZwx8F9jasIsi1yoyIR8r6etMtW8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531400454-25372211-1277751301=:25490"
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531400454-25372211-1277751301=:25490
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 28 Jun 2010, Pekka Enberg wrote:

> > Hackbench was frequently cited in performance tests. Which benchmarks
> > would be of interest?  I am off this week so dont expect a fast response
> > from me.
> 
> I guess "netperf TCP_RR" is the most interesting one because that's a
> known benchmark where SLUB performs poorly when compared to SLAB.
> Mel's extensive slab benchmarks are also worth looking at:
> 
> http://lkml.indiana.edu/hypermail/linux/kernel/0902.0/00745.html
> 

In addition to that benchmark, which regresses on systems with larger 
numbers of cpus, you had posted results for slub vs slab for kernbench, 
aim9, and sysbench before slub was ever merged.  If you're going to use 
slab-like queueing in slub, it would be interesting to see if these 
particular benchmarks regress once again.
--531400454-25372211-1277751301=:25490--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
