Date: Tue, 10 Jun 2008 15:37:02 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH -mm 13/25] Noreclaim LRU Infrastructure
Message-ID: <20080610153702.4019e042@cuia.bos.redhat.com>
In-Reply-To: <Pine.LNX.4.64.0806101214190.17798@schroedinger.engr.sgi.com>
References: <20080606202838.390050172@redhat.com>
	<20080606202859.291472052@redhat.com>
	<20080606180506.081f686a.akpm@linux-foundation.org>
	<20080608163413.08d46427@bree.surriel.com>
	<20080608135704.a4b0dbe1.akpm@linux-foundation.org>
	<20080608173244.0ac4ad9b@bree.surriel.com>
	<20080608162208.a2683a6c.akpm@linux-foundation.org>
	<20080608193420.2a9cc030@bree.surriel.com>
	<20080608165434.67c87e5c.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0806101214190.17798@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jun 2008 12:17:23 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Sun, 8 Jun 2008, Andrew Morton wrote:
> 
> > And it will take longer to get those problems sorted out if 32-bt
> > machines aren't even compiing the new code in.
> 
> The problem is going to be less if we dependedn on 
> CONFIG_PAGEFLAGS_EXTENDED instead of 64 bit. This means that only certain 
> 32bit NUMA/sparsemem configs cannot do this due to lack of page flags.
> 
> I did the pageflags rework in part because of Rik's project.

I think your pageflags work freed up a number of bits on 32
bit systems, unless someone compiles a 32 bit system with
support for 4 memory zones (2 bits ZONE_SHIFT) and 64 NUMA
nodes (6 bits NODE_SHIFT), in which case we should still
have 24 bits for flags.

Of course, having 64 NUMA nodes and a ZONE_SHIFT of 2 on
a 32 bit system is probably total insanity already.  I
suspect very few people compile 32 bit with NUMA at all,
except if it is an architecture that uses DISCONTIGMEM
instead of zones, in which case ZONE_SHIFT is 0, which
will free up space too :)

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
