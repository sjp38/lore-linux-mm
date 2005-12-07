Message-ID: <43976949.8010205@yahoo.com.au>
Date: Thu, 08 Dec 2005 09:59:21 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC 1/3] Framework for accurate node based statistics
References: <20051206182843.19188.82045.sendpatchset@schroedinger.engr.sgi.com> <439619F9.4030905@yahoo.com.au> <Pine.LNX.4.62.0512061536001.20580@schroedinger.engr.sgi.com> <439684C0.9090107@yahoo.com.au> <Pine.LNX.4.62.0512071026360.24516@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0512071026360.24516@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Wed, 7 Dec 2005, Nick Piggin wrote:
> 
> 
>>Sorry, I think I meant: why don't you just use the "add all counters
>>from all per-cpu of the node" in order to find the node-statistic?
> 
> 
> which function is that?
> 

I'm thinking of get_page_state_node... but that's not quite the same
thing. I guess sum all per-CPU counters from all zones in the node,
but that's going to be costly on big machines.

So I'm not sure, I guess I don't have any bright ideas... there is the
batching approach used by current pagecache_acct - is something like
that not sufficient either?

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
