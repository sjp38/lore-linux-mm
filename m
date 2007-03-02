Date: Fri, 2 Mar 2007 09:35:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
Message-Id: <20070302093501.34c6ef2a.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0703020919350.16719@schroedinger.engr.sgi.com>
References: <20070301101249.GA29351@skynet.ie>
	<20070301160915.6da876c5.akpm@linux-foundation.org>
	<45E842F6.5010105@redhat.com>
	<20070302085838.bcf9099e.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0703020919350.16719@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mel@skynet.ie>, npiggin@suse.de, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@linux-foundation.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2 Mar 2007 09:23:49 -0800 (PST) Christoph Lameter <clameter@engr.sgi.com> wrote:

> On Fri, 2 Mar 2007, Andrew Morton wrote:
> 
> > > Linux is *not* happy on 256GB systems.  Even on some 32GB systems
> > > the swappiness setting *needs* to be tweaked before Linux will even
> > > run in a reasonable way.
> > 
> > Please send testcases.
> 
> It is not happy if you put 256GB into one zone.

Oh come on.  What's the workload?  What happens?  system time?  user time?
kernel profiles?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
