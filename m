Message-ID: <440424CA.5070206@yahoo.com.au>
Date: Tue, 28 Feb 2006 21:24:10 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: vDSO vs. mm : problems with ppc vdso
References: <1141105154.3767.27.camel@localhost.localdomain>	 <20060227215416.2bfc1e18.akpm@osdl.org>	 <1141106896.3767.34.camel@localhost.localdomain>	 <20060227222055.4d877f16.akpm@osdl.org> <1141108220.3767.43.camel@localhost.localdomain>
In-Reply-To: <1141108220.3767.43.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, hugh@veritas.com, paulus@samba.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt wrote:

>>>Do you gus see any other case where my "special" vma & those kernel
>>>pages in could be a problem ?
>>
>>It sounds just like a sound card DMA buffer to me - that's a solved
>>problem?  (Well, we keep unsolving it, but it's a relatively common
>>pattern).
> 
> 
> Might be ... though I though the later had VM_RESERVED or some similar
> thing ... the trick with that vma is that i don't want any of these
> things to allow for COW ... But yeah, it _looks_ like it will just work
> (well... it appears to work so far anyway....)
> 

You should be OK. VM_RESERVED itself is something of an anachronism
these days. If you're not getting your page from the page allocator
then you'll want to make sure each of their count, and mapcount is
reset before allowing them to be mapped.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
