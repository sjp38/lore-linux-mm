Message-ID: <45F61C34.4050700@yahoo.com.au>
Date: Tue, 13 Mar 2007 14:36:20 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Remove page flags for software suspend
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com> <20070228101403.GA8536@elf.ucw.cz> <Pine.LNX.4.64.0702280724540.16552@schroedinger.engr.sgi.com> <200702281813.04643.rjw@sisk.pl> <45E6EEC5.4060902@yahoo.com.au> <Pine.LNX.4.64.0703011744500.11812@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0703011744500.11812@blonde.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Christoph Lameter <clameter@engr.sgi.com>, Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Sorry to take so long to reply. I was having issues with this account.

Hugh Dickins wrote:
> On Thu, 1 Mar 2007, Nick Piggin wrote:
> 
>>Let's make sure that no more backdoor page flags get allocated without
>>going through the linux-mm list to work out whether we really need it
>>or can live without it...
> 
> 
> On Fri, 2 Mar 2007, Nick Piggin wrote:
> 
>>I need one bit for lockless pagecache ;)
> 
> 
> Is that still your PageNoNewRefs thing?

Yes.

> What was wrong with my atomic_cmpxchg suggestion?

It is a very good suggestion. I think I ran into an issue where I
had wanted to set PG_nonewrefs for a page with an elevated refcount
or some other issue like that. Can't remember exactly -- I think it
is fixable by reworking some code, but I had wanted to do taht as a
subsequent patch.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
