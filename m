Message-ID: <44D41607.1060201@yahoo.com.au>
Date: Sat, 05 Aug 2006 13:52:39 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch][rfc] possible lock_page fix for Andrea's nopage vs invalidate
 race?
References: <44CF3CB7.7030009@yahoo.com.au> <Pine.LNX.4.64.0608031526400.15351@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0608031526400.15351@blonde.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> (David, I've added you to CC because way down below
> there's an issue of interaction with page_mkwrite.)
> 
> On Tue, 1 Aug 2006, Nick Piggin wrote:
> 
>>Just like to get some thoughts on another possible approach to this
>>problem, and whether my changelog and implementation actually capture
> 
> 
> Good changelog, promising implementation.

... thanks for the thorough review, Hugh, as always. I'll find
time to respond early next week.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
