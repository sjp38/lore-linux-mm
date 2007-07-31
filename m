Date: Tue, 31 Jul 2007 12:20:18 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc] [patch] mm: zone_reclaim fix for pseudo file systems
In-Reply-To: <20070731082751.GB7316@localdomain>
Message-ID: <Pine.LNX.4.64.0707311218410.6093@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0707301725280.25686@schroedinger.engr.sgi.com>
 <20070731015647.GC32468@localdomain> <Pine.LNX.4.64.0707301858280.26859@schroedinger.engr.sgi.com>
 <20070730192721.eb220a9d.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707301934300.27364@schroedinger.engr.sgi.com>
 <20070730214756.c4211678.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707302156440.30284@schroedinger.engr.sgi.com>
 <20070730221736.ccf67c86.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707302224190.30889@schroedinger.engr.sgi.com>
 <20070730225809.ed0a95ff.akpm@linux-foundation.org> <20070731082751.GB7316@localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Tue, 31 Jul 2007, Ravikiran G Thirumalai wrote:

> Well, we have used RAMFS with 2.6.17 kernels with reasonable performance.
> What we saw here was a regression from earlier behavior.  2.6.17 never went
> into reclaim with this kind of workload:

2.6.17 had a time based heuristic. It would frequently needlessly scan for 
pages. The VM counters enabled the determination of unmappped pages which 
allowed the determination if it makes sense to scan without timeout.

> >From what I can see with .21 and .22, going into reclaim is a problem rather
> than reclaim efficiency itself. Sure, if unreclaimable pages are not on LRU
> it would be good, but the main problem for my narrow eyes is going into
> reclaim when there are no reclaimable pages, and the fact that benchmark
> works as expected with the fixed arithmetic reinforces that impression.

The problem is that zone reclaim assumes unmapped pagecache pages are 
easily reclaimable. That is the only thing that zone reclaim is after. All 
other reclaim happens in regular reclaim.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
