Message-ID: <46D10721.7070406@redhat.com>
Date: Sun, 26 Aug 2007 00:52:49 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/7] Postphone reclaim laundry to write at high water marks
References: <20070820215040.937296148@sgi.com>  <1187692586.6114.211.camel@twins>  <Pine.LNX.4.64.0708211347480.3082@schroedinger.engr.sgi.com>  <1187730812.5463.12.camel@lappy>  <Pine.LNX.4.64.0708211418120.3267@schroedinger.engr.sgi.com>  <1187734144.5463.35.camel@lappy>  <Pine.LNX.4.64.0708211532560.5728@schroedinger.engr.sgi.com>  <1187766156.6114.280.camel@twins>  <Pine.LNX.4.64.0708221157180.13813@schroedinger.engr.sgi.com> <1187813025.5463.85.camel@lappy> <Pine.LNX.4.64.0708221306080.15775@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0708221306080.15775@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Wed, 22 Aug 2007, Peter Zijlstra wrote:
> 
>>> That is an extreme case that AFAIK we currently ignore and could be 
>>> avoided with some effort.
>> Its not extreme, not even rare, and its handled now. Its what
>> PF_MEMALLOC is for.
> 
> No its not. If you have all pages allocated as anonymous pages and your 
> writeout requires more pages than available in the reserves then you are 
> screwed either way regardless if you have PF_MEMALLOC set or not.

Only if the _first_ writeout needs more pages.

If the sum of all writeouts need more pages than you have
available, that is fine.  After all, buffer heads and some
other metadata is freed on IO completion.

Recursive reclaim will also be able to free the data pages
after IO completion, and really fix the problem.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
