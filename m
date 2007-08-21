Message-ID: <46CB5C89.2070807@redhat.com>
Date: Tue, 21 Aug 2007 17:43:37 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/7] Postphone reclaim laundry to write at high water marks
References: <20070820215040.937296148@sgi.com>  <1187692586.6114.211.camel@twins>  <Pine.LNX.4.64.0708211347480.3082@schroedinger.engr.sgi.com> <1187730812.5463.12.camel@lappy> <Pine.LNX.4.64.0708211418120.3267@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0708211418120.3267@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:

> I want general improvements to reclaim to address the issues that you see 
> and other issues related to reclaim instead of the strange code that makes 
> PF_MEMALLOC allocs compete for allocations from a single slab and putting 
> logic into the kernel to decide which allocs to fail. We can reclaim after 
> all. Its just a matter of finding the right way to do this. 

The simplest way of achieving that would be to allow
recursion of the page reclaim code, under the condition
that the second level call can only reclaim clean pages,
while the "outer" call does what the VM does today.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
