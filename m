Message-ID: <439619F9.4030905@yahoo.com.au>
Date: Wed, 07 Dec 2005 10:08:41 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC 1/3] Framework for accurate node based statistics
References: <20051206182843.19188.82045.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20051206182843.19188.82045.sendpatchset@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> [RFC] Framework for accurate node based statistics
> 
> Currently we have various vm counters that are split per cpu. This arrangement
> does not allow access to per node statistics that are important to optimize
> VM behavior for NUMA architectures. All one can say from the per_cpu
> differential variables is how much a certain variable was changed by this cpu
> without being able to deduce how many pages in each node are of a certain type.
> 
> This patch introduces a generic framework to allow accurate per node vm
> statistics through a large per node and per cpu array. The numbers are
> consolidated when the slab drainer runs (every 3 seconds or so) into global
> and per node counters. VM functions can then check these statistics by
> simply accessing the node specific or global counter.
> 
> A significant problem with this approach is that the statistics are only
> accumulated every 3 seconds or so. I have tried various other approaches
> but they typically end up with having to add atomic variables to critical
> VM paths. I'd be glad if someone else had a bright idea on how to improve
> the situation.
> 

Why not have per-node * per-cpu counters?

Or even use the current per-zone * per-cpu counters, and work out your
node details from there?

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
