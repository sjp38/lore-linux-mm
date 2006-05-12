Message-ID: <4464424E.2080501@cyberone.com.au>
Date: Fri, 12 May 2006 18:07:42 +1000
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/3] tracking dirty pages in shared mappings -V4
References: <1146861313.3561.13.camel@lappy>	 <445CA22B.8030807@cyberone.com.au> <1146922446.3561.20.camel@lappy>	 <445CA907.9060002@cyberone.com.au> <1146929357.3561.28.camel@lappy>	 <Pine.LNX.4.64.0605072338010.18611@schroedinger.engr.sgi.com>	 <1147116034.16600.2.camel@lappy>	 <Pine.LNX.4.64.0605082234180.23795@schroedinger.engr.sgi.com>	 <1147207458.27680.19.camel@lappy> <20060511080220.48688b40.akpm@osdl.org>	 <4463EA16.5090208@cyberone.com.au>  <20060511213045.32b41aa6.akpm@osdl.org> <1147417561.8951.17.camel@twins>
In-Reply-To: <1147417561.8951.17.camel@twins>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@osdl.org>, clameter@sgi.com, torvalds@osdl.org, ak@suse.de, rohitseth@google.com, mbligh@google.com, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Peter Zijlstra wrote:

>On Thu, 2006-05-11 at 21:30 -0700, Andrew Morton wrote:
>
>>
>>We just lost that pte dirty bit, and hence the user's data.
>>
>
>I thought that at the time we clean PAGECACHE_TAG_DIRTY the page is in
>flight to disk.
>

No.

>Now that I look at it again, perhaps the page_wrprotect() call in
>clear_page_dirty_for_io()
>should be in test_set_page_writeback().
>

No. The logical operation is clearing the dirty bits from the ptes. Such
an operation would be valid even if we didn't set the ptes readonly.

And clearing dirty belongs in clear_page_dirty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
