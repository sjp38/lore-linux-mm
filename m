Date: Thu, 15 Feb 2007 21:25:53 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Remove unswappable anonymous pages off the LRU
In-Reply-To: <20070215211617.a6e1cd5b.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0702152122520.2290@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702151300500.31366@schroedinger.engr.sgi.com>
 <20070215171355.67c7e8b4.akpm@linux-foundation.org> <45D50B79.5080002@mbligh.org>
 <20070215174957.f1fb8711.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702151830080.1471@schroedinger.engr.sgi.com>
 <20070215184800.e2820947.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702151849030.1511@schroedinger.engr.sgi.com>
 <20070215191858.1a864874.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702151929180.1696@schroedinger.engr.sgi.com>
 <20070215194258.a354f428.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702151945090.1696@schroedinger.engr.sgi.com>
 <45D52F89.5020008@redhat.com> <Pine.LNX.4.64.0702152015110.1696@schroedinger.engr.sgi.com>
 <20070216135714.669701b4.kamezawa.hiroyu@jp.fujitsu.com>
 <20070215211617.a6e1cd5b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, riel@redhat.com, mbligh@mbligh.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

On Thu, 15 Feb 2007, Andrew Morton wrote:

> hm.  We can calculate page_zone(page) from the pfn.  And I suspect we can
> do that locklessly too.  I bet a nice tight implementation of that would be
> efficient enough and it'll reclaim heaps of flags.

You mean encode the node and the zone_id in the pfn? Ummm... That would 
get us into lots of trouble with pfn_to_page and friends.

The sparsemem section field could be available. A virtual 
memmap based implementation would not need the section number and would 
get rid of the sparsemem table lookups.Problem is that we cannot do it on 
32 bit platforms because of the lack of virtual memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
