Message-ID: <447FAC32.9010606@yahoo.com.au>
Date: Fri, 02 Jun 2006 13:10:42 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [Patch 0/17] PTI: Explation of Clean Page Table Interface
References: <Pine.LNX.4.61.0605301334520.10816@weill.orchestra.cse.unsw.EDU.AU> <yq0irnot028.fsf@jaguar.mkp.net> <Pine.LNX.4.61.0605301830300.22882@weill.orchestra.cse.unsw.EDU.AU> <447C055A.9070906@sgi.com> <Pine.LNX.4.62.0605311111020.13018@weill.orchestra.cse.unsw.EDU.AU> <447CFEAA.5070206@yahoo.com.au> <Pine.LNX.4.62.0606011313350.29379@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <Pine.LNX.4.62.0606011313350.29379@weill.orchestra.cse.unsw.EDU.AU>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Cc: Jes Sorensen <jes@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Paul Cameron Davies wrote:
> On Wed, 31 May 2006, Nick Piggin wrote:

>> And unless it is something pretty significant, I'd almost bet that Linus,
>> if nobody else, will veto it. Our radix-tree v->p data structure is
>> fairly clean, performant, etc. It matches the logical->physical radix
>> tree data structure we use for pagecache as well.
> 
> 
> Being able to change the page table on a 64 bit machine will
> be a huge advantage into the future when applications really start to
> make use of the 64 bit address space.  The current trie (multi level
> page table - MLPT) is not going to perform against more
> sophisticated data structures in a sparsely occupied 64 bit address space

OK, this is what I mean by better performing. It does not have to
have *zero* performance regressions across the board, but simply
something that tips the cost/benefit.

That does imply that the framework itself would never get included,
without something behind it that does perform better. Which I assume
is your plan.


The release early approach is a good one, so continue to post code
and/or results on linux-mm. I do happen to think you'll have a pretty
hard time getting this in at all, but good luck to you ;)

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
