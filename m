Date: Thu, 15 Feb 2007 20:24:25 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] Remove unswappable anonymous pages off the LRU
Message-Id: <20070215202425.bd9d028e.akpm@linux-foundation.org>
In-Reply-To: <45D52F89.5020008@redhat.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Christoph Lameter <clameter@sgi.com>, Martin Bligh <mbligh@mbligh.org>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Feb 2007 23:14:01 -0500 Rik van Riel <riel@redhat.com> wrote:

> Christoph Lameter wrote:
> 
> > I tinkered with some similar radical ideas lately. Maybe a bit vector
> > could be used instead? For 1G of memory we would need 
> > 
> > 2^(30 - PAGE_SHIFT / 8 = 2^(30-12-3) = 2^15 = 32k bytes of a bitmap.
> > 
> > Seems to be reasonable?
> 
> At that point, wouldn't it be easier to simply increase
> the size of struct page?  I don't think they're power of
> two sized anyway, at least on 64 bit architectures.

That gives us an additional 32 bits in one hit whereas the external bitmap
allows us to fine-tune it.

Doing neither is of course best..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
