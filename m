Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
References: <20070814142103.204771292@sgi.com>
	<20070815122253.GA15268@wotan.suse.de>
	<1187183526.6114.45.camel@twins>
From: Andi Kleen <andi@firstfloor.org>
Date: 15 Aug 2007 16:15:35 +0200
In-Reply-To: <1187183526.6114.45.camel@twins>
Message-ID: <p731we43muw.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra <a.p.zijlstra@chello.nl> writes:
> 
> Christoph's suggestion to set min_free_kbytes to 20% is ridiculous - nor
> does it solve all deadlocks :-(

A minimum enforced reclaimable non dirty threshold wouldn't be
that ridiculous though. So the memory could be used, just not
for dirty data.

His patchkit essentially turns the GFP_ATOMIC requirements 
from free to easily reclaimable. I see that as an general improvement.

I remember sct talked about this many years ago and it's still
a good idea.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
