Date: Wed, 15 Aug 2007 13:32:03 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
In-Reply-To: <1187186120.6114.56.camel@twins>
Message-ID: <Pine.LNX.4.64.0708151330180.7326@schroedinger.engr.sgi.com>
References: <20070814142103.204771292@sgi.com>  <20070815122253.GA15268@wotan.suse.de>
 <1187183526.6114.45.camel@twins>  <p731we43muw.fsf@bingen.suse.de>
 <1187186120.6114.56.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Aug 2007, Peter Zijlstra wrote:

> The thing I strongly objected to was the 20%.

Well then set it to 10%. We have min_free_kbytes now and so we are used
to these limits.

> Also his approach misses the threshold - the extra condition needed to
> break out of the various network deadlocks. There is no point that says
> - ok, and now we're in trouble, drop anything non-critical. Without that
> you'll always run into a wall.

Networking?

> That is his second patch-set, and I do worry about the irq latency that
> that will introduce. It very much has the potential to ruin everything
> that cares about interactiveness or latency.

Where is the patchset introducing additional latencies? Most of the time 
it only saves and restores flags. We already enable and disable interrupts 
in the reclaim path but we assume that interupts are always enabled when 
we enter reclaim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
