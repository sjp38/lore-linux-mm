Subject: Re: [rfc] [patch] mm: zone_reclaim fix for pseudo file systems
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0707301331050.17543@schroedinger.engr.sgi.com>
References: <20070727232753.GA10311@localdomain>
	 <20070730132314.f6c8b4e1.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0707301331050.17543@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 30 Jul 2007 17:12:40 -0400
Message-Id: <1185829960.5492.94.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ravikiran G Thirumalai <kiran@scalex86.org>, linux-mm@kvack.org, Christoph Lameter <clameter@cthulhu.engr.sgi.com>, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Mon, 2007-07-30 at 13:31 -0700, Christoph Lameter wrote:
> On Mon, 30 Jul 2007, Andrew Morton wrote:
> 
> > It is a numa-specific change which adds overhead to non-NUMA builds :(
> 
> It could be generalized to fix the other issues that we have with 
> unreclaimable pages.
> 

For example, see the following patches that I posted in response to a
discussion between Andrew, Rik van Riel and Andrea Arcangeli to
resounding silence [for which, perhaps, I should be grateful?]: 

http://marc.info/?l=linux-mm&m=118315682007044&w=4
http://marc.info/?l=linux-mm&m=118315703313729&w=4
http://marc.info/?l=linux-mm&m=118315713323641&w=4
http://marc.info/?l=linux-mm&m=118315742025334&w=4

[By the way:  I have another experimental patch in this series that uses
Rik's page_anon() function from his "split LRU lists" patch to detect
swap backed pages and push them to the "no reclaim list" when no swap
space is available.]

I haven't thought about it much, but perhaps my "page_reclaimable()"
function could be taught to exclude RAMFS pages as well?

Later,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
