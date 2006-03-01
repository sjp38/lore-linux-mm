Message-ID: <44050939.4060303@yahoo.com.au>
Date: Wed, 01 Mar 2006 13:38:49 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: vDSO vs. mm : problems with ppc vdso
References: <1141105154.3767.27.camel@localhost.localdomain>	 <20060227215416.2bfc1e18.akpm@osdl.org>	 <1141106896.3767.34.camel@localhost.localdomain>	 <20060227222055.4d877f16.akpm@osdl.org>	 <1141108220.3767.43.camel@localhost.localdomain>	 <440424CA.5070206@yahoo.com.au>	 <Pine.LNX.4.61.0602281213540.7059@goblin.wat.veritas.com>	 <440505D0.2030802@yahoo.com.au> <1141180019.4157.12.camel@localhost.localdomain>
In-Reply-To: <1141180019.4157.12.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, paulus@samba.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt wrote:
> On Wed, 2006-03-01 at 13:24 +1100, Nick Piggin wrote:

>>mapcount should be reset, to avoid the bug in page_remove_rmap.
> 
> 
> Can you be more explicit ?
> 

reset_page_mapcount() -- if you don't already know that mapcount is
the right value.

It might not be unreasonable to say "bah my arch initialises it to
0, and I didn'tcare for it to be accounted in nr_mapped anyway",
however not using the mapcount accessors means you might break in
future if they change.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
