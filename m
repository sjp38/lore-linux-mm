Date: Thu, 15 Feb 2007 21:16:17 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] Remove unswappable anonymous pages off the LRU
Message-Id: <20070215211617.a6e1cd5b.akpm@linux-foundation.org>
In-Reply-To: <20070216135714.669701b4.kamezawa.hiroyu@jp.fujitsu.com>
References: <Pine.LNX.4.64.0702151300500.31366@schroedinger.engr.sgi.com>
	<20070215171355.67c7e8b4.akpm@linux-foundation.org>
	<45D50B79.5080002@mbligh.org>
	<20070215174957.f1fb8711.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702151830080.1471@schroedinger.engr.sgi.com>
	<20070215184800.e2820947.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702151849030.1511@schroedinger.engr.sgi.com>
	<20070215191858.1a864874.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702151929180.1696@schroedinger.engr.sgi.com>
	<20070215194258.a354f428.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702151945090.1696@schroedinger.engr.sgi.com>
	<45D52F89.5020008@redhat.com>
	<Pine.LNX.4.64.0702152015110.1696@schroedinger.engr.sgi.com>
	<20070216135714.669701b4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <clameter@sgi.com>, riel@redhat.com, mbligh@mbligh.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

On Fri, 16 Feb 2007 13:57:14 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 15 Feb 2007 20:15:46 -0800 (PST)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > On Thu, 15 Feb 2007, Rik van Riel wrote:
> > 
> > > Christoph Lameter wrote:
> > > 
> > > > I tinkered with some similar radical ideas lately. Maybe a bit vector
> > > > could be used instead? For 1G of memory we would need 
> > > > 2^(30 - PAGE_SHIFT / 8 = 2^(30-12-3) = 2^15 = 32k bytes of a bitmap.
> > > > 
> > > > Seems to be reasonable?
> > > 
> > > At that point, wouldn't it be easier to simply increase
> > > the size of struct page?  I don't think they're power of
> > > two sized anyway, at least on 64 bit architectures.
> > 
> > On 64 bit platforms we can add one unsigned long to get from 56 to 64 
> > bytes.
> > 
> 
> I sometimes dreams 
> ==
> struct page {
> 	...
> 	struct zone	*zone;
> 	...
> };
> #define page_zone(page)		(page)->zone
> ==
> but never tried ;)

hm.  We can calculate page_zone(page) from the pfn.  And I suspect we can
do that locklessly too.  I bet a nice tight implementation of that would be
efficient enough and it'll reclaim heaps of flags.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
