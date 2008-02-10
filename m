Date: Mon, 11 Feb 2008 00:24:01 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: SLUB tbench regression due to page allocator deficiency
Message-ID: <20080210232401.GA5621@wotan.suse.de>
References: <Pine.LNX.4.64.0802091332450.12965@schroedinger.engr.sgi.com> <20080209143518.ced71a48.akpm@linux-foundation.org> <Pine.LNX.4.64.0802091549120.13328@schroedinger.engr.sgi.com> <20080210024517.GA32721@wotan.suse.de> <Pine.LNX.4.64.0802091938160.14089@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802091938160.14089@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Pekka J Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Sat, Feb 09, 2008 at 07:39:17PM -0800, Christoph Lameter wrote:
> On Sun, 10 Feb 2008, Nick Piggin wrote:
> 
> > What kind of allocating and freeing of pages are you talking about? Are
> > you just measuring single threaded performance?
> 
> What I did was (on an 8p, may want to tune this to the # procs you have):
> 
> 1. Run tbench_srv on console
> 
> 2. run tbench 8 from an ssh session

OK, that's easy... You did it with an SMP kernel, right? (I only have a
8p NUMA, but I should be able to turn on cacheline interleaving and
run an SMP kernel on it).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
