Message-ID: <42E575C6.2010802@yahoo.com.au>
Date: Tue, 26 Jul 2005 09:29:10 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: PageReserved removal from swsusp
References: <42E44294.5020408@yahoo.com.au> <1122265909.6144.106.camel@localhost> <42E46FF5.5080805@yahoo.com.au> <42E4852D.7010209@yahoo.com.au> <Pine.LNX.4.61.0507251332010.13673@goblin.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.61.0507251332010.13673@goblin.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: ncunningham@cyclades.com, Linux Memory Management <linux-mm@kvack.org>, Pavel Machek <pavel@suse.cz>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Mon, 25 Jul 2005, Nick Piggin wrote:
> 
>>However I'm not sure that I really like the use of
>>flags == 0xffffffff to indicate the page is unusable. For one thing it
>>may confuse things that walk physical pages, and for another it can
>>easily break if someone clears a flag of an 'unusable' page.
> 
> 
> I don't like that either.  Setting all the flags seems to maximize the
> chance of error somewhere.  Perhaps a magic number in one of the other
> struct page fields would work more safely.  Or perhaps just leave it
> as its own flag bit for now, and later go on a separate free-up-some-
> flags exercise.
> 

OK I'll leave it using PageReserved, and we can rethink it later.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
