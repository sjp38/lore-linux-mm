Subject: Re: [RFC] Remove unswappable anonymous pages off the LRU
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0702160208530.21862@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702151300500.31366@schroedinger.engr.sgi.com>
	 <20070215171355.67c7e8b4.akpm@linux-foundation.org>
	 <45D50B79.5080002@mbligh.org>
	 <20070215174957.f1fb8711.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0702151830080.1471@schroedinger.engr.sgi.com>
	 <20070215184800.e2820947.akpm@linux-foundation.org>
	 <1171613727.24923.54.camel@twins>
	 <Pine.LNX.4.64.0702160208530.21862@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 16 Feb 2007 11:17:36 +0100
Message-Id: <1171621056.24923.61.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Martin Bligh <mbligh@mbligh.org>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-02-16 at 02:10 -0800, Christoph Lameter wrote:
> On Fri, 16 Feb 2007, Peter Zijlstra wrote:
> 
> > On Thu, 2007-02-15 at 18:48 -0800, Andrew Morton wrote:
> > 
> > > The two swsusp bits can be removed: they're only needed at suspend/resume
> > > time and can be replaced by an external data structure.
> > 
> > I once had a talk with Rafael, and he said it would be possible to rid
> > us of PG_nosave* with the now not so new bitmap code that is used to
> > handle swsusp of highmem pages.
> 
> Well we can just shift the stuff into the power subsystem I think. Like 
> this? Compiles but not tested.

That would work, however as Andrew pointed out, this data is only ever
used at suspend/resume time. I think we can postpone allocating this
bitmap until then and free it afterwards.

However I'm quite out of my depths here, so I'll leave more constructive
comments to Rafael.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
