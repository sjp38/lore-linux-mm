Message-ID: <44220614.1090101@yahoo.com.au>
Date: Thu, 23 Mar 2006 13:21:08 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 00/34] mm: Page Replacement Policy Framework
References: <20060322223107.12658.14997.sendpatchset@twins.localnet> <20060322145132.0886f742.akpm@osdl.org>
In-Reply-To: <20060322145132.0886f742.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bob.picco@hp.com, iwamoto@valinux.co.jp, christoph@lameter.com, wfg@mail.ustc.edu.cn, npiggin@suse.de, torvalds@osdl.org, riel@redhat.com, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> 
>>
>>This patch-set introduces a page replacement policy framework and 4 new 
>>experimental policies.
> 
> 
> Holy cow.
> 
> 
>>The page replacement algorithm determines which pages to swap out.
>>The current algorithm has some problems that are increasingly noticable, even
>>on desktop workloads.
> 
> 
> Rather than replacing the whole lot four times I'd really prefer to see
> precise descriptions of these problems, see if we can improve the situation
> incrementally rather than wholesale slash-n-burn...
> 

The other thing is that a lot of the "policy" stuff you've abstracted
out is actually low-level "mechanism" stuff that has implications beyond
page reclaim. Taking a refcount on lru pages, for example.

Also, as you work and find incremental improvements to the current code,
you should be submitting them (eg. patch 25, or patch 1) rather than
sitting on them and sending them in a huge patchset where they don't
really belong.

Some of the API names aren't very nice either. It's great that you want
to keep the namespace consistent, but it shouldn't be at the expense of
more descriptive names, and having the page_replace_ prefix itself makes
many functions read like crap. I'd suggest something like a pgrep_
prefix and try to make the rest of the name make sense.

Aside from all that, I'm with Andrew in that problems need to be
identified first and foremost. But also I don't like the chances of this
whole framework flying at all -- Linus vetoed a similar framework for
sched.c that was actually a reasonable API, with little or no
consequences outside sched.c. With good reason.

Nice work, though :)

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
