Date: Tue, 30 Jul 2002 10:13:27 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [RFC] start_aggressive_readahead
Message-ID: <20020730171327.GC29537@holomorphy.com>
References: <F245ABF4-A3D6-11D6-9922-000393829FA4@cs.amherst.edu> <644994853.1028020916@[10.10.2.3]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <644994853.1028020916@[10.10.2.3]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: Scott Kaplan <sfkaplan@cs.amherst.edu>, Andrew Morton <akpm@zip.com.au>, Rik van Riel <riel@conectiva.com.br>, Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2002 at 09:21:57AM -0700, Martin J. Bligh wrote:
> Would it not be easier to actually calculate (statistically) the 
> read-ahead window, rather than actually tweaking it empirically?
> If we're getting misses, there could be at least two causes - 

I wonder where these stats should really be kept. They seem to be in
the vma which probably doesn't fly too well when 20K threads are
pounding on different chunks of the same thing. Each could do locally
sequential reads and look random to the perspective of per-vma stats.

This probably gets worse if different threads are stomping in different
patterns, e.g. one sequential, one random. They also seem to lack any
way to cooperate since the hints are kept per-vma. It's also probably
easier to predict the behavior of a single task.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
