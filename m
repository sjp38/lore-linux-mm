Message-ID: <436443A0.1000508@yahoo.com.au>
Date: Sun, 30 Oct 2005 14:53:04 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH]: Clean up of __alloc_pages
References: <20051028183326.A28611@unix-os.sc.intel.com>	<20051029184728.100e3058.pj@sgi.com>	<4364296E.1080905@yahoo.com.au>	<20051029191946.1832adaf.pj@sgi.com>	<436430BA.4010606@yahoo.com.au> <20051029200634.778a57d6.pj@sgi.com>
In-Reply-To: <20051029200634.778a57d6.pj@sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: rohit.seth@intel.com, akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Paul Jackson wrote:
> Nick, replying to pj:
> 

>>Hmm, where is the other callsite? 
> 
> 
> The other callsite is mm/swap_prefetch.c:prefetch_get_page(), from Con
> Kolivas's mm-implement-swap-prefetching.patch patch in *-mm, dated
> about six days ago.
> 

OK, I haven't looked at those patches really. I think some of that
stuff should go into page_alloc.c and I'd prefer to keep
buffered_rmqueue static.

But no matter for the cleanup patch at hand: let's leave the inline
off, and the compiler will do the right thing if it is static and
there is just a single call site (and I think newer gccs will do
function versioning if there are constant arguments).

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
