Message-ID: <440505D0.2030802@yahoo.com.au>
Date: Wed, 01 Mar 2006 13:24:16 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: vDSO vs. mm : problems with ppc vdso
References: <1141105154.3767.27.camel@localhost.localdomain>  <20060227215416.2bfc1e18.akpm@osdl.org>  <1141106896.3767.34.camel@localhost.localdomain>  <20060227222055.4d877f16.akpm@osdl.org> <1141108220.3767.43.camel@localhost.localdomain> <440424CA.5070206@yahoo.com.au> <Pine.LNX.4.61.0602281213540.7059@goblin.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.61.0602281213540.7059@goblin.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, paulus@samba.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Tue, 28 Feb 2006, Nick Piggin wrote:
> 
>>You should be OK. VM_RESERVED itself is something of an anachronism
>>these days. If you're not getting your page from the page allocator
>>then you'll want to make sure each of their count, and mapcount is
>>reset before allowing them to be mapped.
> 
> 
> Yes, it's fine that VM_RESERVED isn't set on it.
> But I don't understand your remarks about count and mapcount at all:
> perhaps you meant to say something else?
> 

Yes, count should be elevated.

mapcount should be reset, to avoid the bug in page_remove_rmap.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
