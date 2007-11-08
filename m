Date: Thu, 08 Nov 2007 15:24:08 -0800 (PST)
Message-Id: <20071108.152408.157342087.davem@davemloft.net>
Subject: Re: Some interesting observations when trying to optimize vmstat
 handling
From: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0711081141180.9694@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0711081141180.9694@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 8 Nov 2007 11:58:58 -0800 (PST)
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, ak@suse.de, mathieu.desnoyers@polymtl.ca
List-ID: <linux-mm.kvack.org>

> The problem with cmpxchg_local here is that the differential has to
> be read before we execute the cmpxchg_local. So the cacheline is
> acquired first in read mode and then made exclusive on executing the
> cmpxchg_local.

I bet this can be defeated by prefetching for a write before
the read, but of course this won't help if the read is
being used to conditionally avoid the cmpxchg_local but I don't
think that's what you're trying to do here.

I've always wanted to add a write prefetch at the beginning of all of
the sparc64 atomic operation primitives because of this problem.
I just never got around to measuring if it's worthwhile or not.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
