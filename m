Date: Wed, 23 May 2007 10:06:22 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/3] slob: rework freelist handling
In-Reply-To: <20070523071809.GC9449@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0705231004140.19822@schroedinger.engr.sgi.com>
References: <20070523045938.GA29045@wotan.suse.de>
 <Pine.LNX.4.64.0705222200420.32184@schroedinger.engr.sgi.com>
 <20070523050333.GB29045@wotan.suse.de> <Pine.LNX.4.64.0705222204460.3135@schroedinger.engr.sgi.com>
 <20070523051152.GC29045@wotan.suse.de> <Pine.LNX.4.64.0705222212200.3232@schroedinger.engr.sgi.com>
 <20070523052206.GD29045@wotan.suse.de> <Pine.LNX.4.64.0705222224380.12076@schroedinger.engr.sgi.com>
 <20070523061702.GA9449@wotan.suse.de> <Pine.LNX.4.64.0705222332530.16738@schroedinger.engr.sgi.com>
 <20070523071809.GC9449@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 23 May 2007, Nick Piggin wrote:

> > The following patch may help a little bit but not much. Hmmm... In order 
> > to reduce the space further we would also have to shrink all caches when 
> > boot is  complete. Elimination of useless caches also would be good. 
> > Do you really want to go into this deeper?
> 
> Well you asked the question what good is SLOB when we have SLUB, and the
> answer, not surprisingly, still seems to be that it is better for memory
> constrained environments.

Well there is not much difference as far as I can see and we have not 
focuses on reducing memory wastage by caching.

> I'm happy to test any patches from you. If you are able to make SLUB as
> space efficient as SLOB on small systems, that would be great, and we
> could talk about replacing that too. I think it would be a hefty task,
> though.

We can never get there given that SLOB has always been broken and we do 
not want to do the same but I think we can get close. I will sent you 
another patch today that will avoid keeping cpu slabs around.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
