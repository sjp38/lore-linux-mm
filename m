Message-ID: <446368DC.1070104@shadowen.org>
Date: Thu, 11 May 2006 17:39:56 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/3] tracking dirty pages in shared mappings -V4
References: <1146861313.3561.13.camel@lappy>	<445CA22B.8030807@cyberone.com.au>	<1146922446.3561.20.camel@lappy>	<445CA907.9060002@cyberone.com.au>	<1146929357.3561.28.camel@lappy>	<Pine.LNX.4.64.0605072338010.18611@schroedinger.engr.sgi.com>	<1147116034.16600.2.camel@lappy>	<Pine.LNX.4.64.0605082234180.23795@schroedinger.engr.sgi.com>	<1147207458.27680.19.camel@lappy> <20060511080220.48688b40.akpm@osdl.org>
In-Reply-To: <20060511080220.48688b40.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, clameter@sgi.com, piggin@cyberone.com.au, torvalds@osdl.org, ak@suse.de, rohitseth@google.com, mbligh@google.com, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> 
>>
>>From: Peter Zijlstra <a.p.zijlstra@chello.nl>
>>
>>People expressed the need to track dirty pages in shared mappings.
>>
>>Linus outlined the general idea of doing that through making clean
>>writable pages write-protected and taking the write fault.
>>
>>This patch does exactly that, it makes pages in a shared writable
>>mapping write-protected. On write-fault the pages are marked dirty and
>>made writable. When the pages get synced with their backing store, the
>>write-protection is re-instated.
>>
>>It survives a simple test and shows the dirty pages in /proc/vmstat.
> 
> 
> It'd be nice to have more that a "simple test" done.  Bugs in this area
> will be subtle and will manifest in unpleasant ways.  That goes for both
> correctness and performance bugs.

I'll kick off some testing of this stack and see what occurs.  Should
appear on t.k.o in due time.

Cheers.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
