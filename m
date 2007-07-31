Date: Tue, 31 Jul 2007 12:50:20 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc] [patch] mm: zone_reclaim fix for pseudo file systems
In-Reply-To: <20070731124642.c43012cd.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0707311247340.11078@schroedinger.engr.sgi.com>
References: <20070727232753.GA10311@localdomain> <20070730132314.f6c8b4e1.akpm@linux-foundation.org>
 <20070731000138.GA32468@localdomain> <20070730172007.ddf7bdee.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707301725280.25686@schroedinger.engr.sgi.com>
 <20070731015647.GC32468@localdomain> <Pine.LNX.4.64.0707301858280.26859@schroedinger.engr.sgi.com>
 <20070730192721.eb220a9d.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707301934300.27364@schroedinger.engr.sgi.com>
 <20070730214756.c4211678.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707302156440.30284@schroedinger.engr.sgi.com>
 <20070730221736.ccf67c86.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707302224190.30889@schroedinger.engr.sgi.com>
 <20070730225809.ed0a95ff.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707302300090.874@schroedinger.engr.sgi.com>
 <20070730231806.da72a7ec.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707311232580.6093@schroedinger.engr.sgi.com>
 <20070731124642.c43012cd.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ravikiran G Thirumalai <kiran@scalex86.org>, linux-mm@kvack.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Tue, 31 Jul 2007, Andrew Morton wrote:

> They're different from Kiran's problem.  Not specifically ramfs and
> zone-reclaim isn't (obviously) involved.  Yes, the solution is probably the
> same one, but it'd be sad to "fix" Kiran's problem via finer-grained zone
> accounting while leaving an undiscovered bug behind.

Zone reclaim would not occur if the counters would accurately describing 
the unmapped pagecache pages that are presumably very easy to reclaim. 
Zone reclaim is not a full reclaim implementation. Its just superficial 
removal of easy to get pages.

> If we're going further down that path we should aim at removing the
> all_unreclaimable logic completely.

I think that is doable if we account for the unreclaimable pages and move 
them off the LRU.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
