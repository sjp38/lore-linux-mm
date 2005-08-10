Date: Wed, 10 Aug 2005 04:40:28 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC 1/3] non-resident page tracking
In-Reply-To: <20050809211305.GA23675@dmt.cnet>
Message-ID: <Pine.LNX.4.61.0508100439510.1888@chimarrao.boston.redhat.com>
References: <20050808201416.450491000@jumble.boston.redhat.com>
 <20050808202110.744344000@jumble.boston.redhat.com> <20050809182517.GA20644@dmt.cnet>
 <1123614926.17222.19.camel@twins> <20050809211305.GA23675@dmt.cnet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Aug 2005, Marcelo Tosatti wrote:

> Well, not really "good approximation" it sounds to me, the sensibility
> goes down to L1_CACHE_LINE/sizeof(u32), which is:
> 
> - 8 on 32-byte cacheline
> - 16 on 64-byte cacheline 
> - 32 on 128-byte cacheline
> 
> Right?
> 
> So the (nice!) refault histogram gets limited to those values?

I agree that 7 would be too small.  I guess I should limit the
minimum size of the nonresident hash bucket to 15 entries...

-- 
All Rights Reversed
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
