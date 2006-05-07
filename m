Message-ID: <445D41F0.800@cyberone.com.au>
Date: Sun, 07 May 2006 10:40:16 +1000
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] tracking dirty pages in shared mappings
References: <1146861313.3561.13.camel@lappy>	 <445CA22B.8030807@cyberone.com.au> <1146922446.3561.20.camel@lappy>	 <445CA907.9060002@cyberone.com.au> <1146929357.3561.28.camel@lappy>
In-Reply-To: <1146929357.3561.28.camel@lappy>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@osdl.org>, Andi Kleen <ak@suse.de>, Rohit Seth <rohitseth@google.com>, Andrew Morton <akpm@osdl.org>, clameter@sgi.com, mbligh@google.com, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:

>On Sat, 2006-05-06 at 23:47 +1000, Nick Piggin wrote:
>
>
>>Yep. Let's not distract from getting the basic mechanism working though.
>>balance_dirty_pages would be patch 2..n ;)
>>
>
>Attached are both a new version of the shared_mapping_dirty patch, and
>balance_dirty_pages; to be applied in that order. 
>
>It makes my testcase survive and not OOM like it used to.
>

Looks OK. I wonder if test_clear_page_dirty could skip the page_wrprotect
entirely? It would speed up cases like truncate that don't care. OTOH, it
looks like several filesystems do not use clear_page_dirty_for_io where
they possibly should be...

Perhaps you could consolidate both checks into test_set_page_writeback()?

Andrew, any ideas?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
