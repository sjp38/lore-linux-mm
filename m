Message-ID: <461C8DC0.1060509@yahoo.com.au>
Date: Wed, 11 Apr 2007 17:26:56 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: remap_file_pages support - lost messages?
References: <200704091612.57964.blaisorblade@yahoo.it>	 <20070409104315.02653a7f.akpm@linux-foundation.org> <1176237622.18017.0.camel@lappy>
In-Reply-To: <1176237622.18017.0.camel@lappy>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Blaisorblade <blaisorblade@yahoo.it>, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> On Mon, 2007-04-09 at 10:43 -0700, Andrew Morton wrote:
> 
>>On Mon, 9 Apr 2007 16:12:57 +0200 Blaisorblade <blaisorblade@yahoo.it> wrote:
>>
>>
>>>Andrew, last week I sent to you the patchset for remap_file_pages protection 
>>>support, against 2.6.21-rc5-mm3. I got no response at all on that, even if I 
>>>thought it would be merged in -mm. What happened? Should I resend it?
>>
>>I saw them, and hung onto them for a week in the hope that someone would
>>get in and review them, but nobody did.
>>
>>So I suppose you should resend, please.  Try cc'ing lkml as well - there
>>seems to be plenty of surplus labour over there ;)
> 
> 
> I intended to go over it in detail, I just haven't found the time
> yet :-(

Ditto. The fault handler / sigsegv code still seems a little bit unfortunate
(if it can't be improved then maybe it can at least be ifdef'ed), however I
hadn't seen the patchset since it had been using some weird pte encoding
conventions. Now that it is using a more formal encoding and its own not
present bit, that part of it looks much cleaner.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
