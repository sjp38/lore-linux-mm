Message-ID: <4365C39F.2080006@yahoo.com.au>
Date: Mon, 31 Oct 2005 18:11:27 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
References: <20051030183354.22266.42795.sendpatchset@skynet.csn.ul.ie>	<20051031055725.GA3820@w-mikek2.ibm.com>	<4365BBC4.2090906@yahoo.com.au> <20051030235440.6938a0e9.akpm@osdl.org>
In-Reply-To: <20051030235440.6938a0e9.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: kravetz@us.ibm.com, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:

>>Despite what people were trying to tell me at Ottawa, this patch
>>set really does add quite a lot of complexity to the page
>>allocator, and it seems to be increasingly only of benefit to
>>dynamically allocating hugepages and memory hot unplug.
> 
> 
> Remember that Rohit is seeing ~10% variation between runs of scientific
> software, and that his patch to use higher-order pages to preload the
> percpu-pages magazines fixed that up.  I assume this means that it provided
> up to 10% speedup, which is a lot.
> 

OK, I wasn't aware of this. I wonder what other approaches we could
try to add a bit of colour to our pages? I bet something simple like
trying to hand out alternate odd/even pages per task might help.

> But the patch caused page allocator fragmentation and several reports of
> gigE Tx buffer allocation failures, so I dropped it.
> 
> We think that Mel's patches will allow us to reintroduce Rohit's
> optimisation.
> 
> 
>>If that is the case, do we really want to make such sacrifices
>>for the huge machines that want these things? What about just
>>making an extra zone for easy-to-reclaim things to live in?
>>
>>This could possibly even be resized at runtime according to
>>demand with the memory hotplug stuff (though I haven't been
>>following that).
>>
>>Don't take this as criticism of the actual implementation or its
>>effectiveness.
>>
> 
> 
> But yes, adding additional complexity is a black mark, and these patches
> add quite a bit.  (Ditto the fine-looking adaptive readahead patches, btw).
> 

They do look quite fine. They seem to get their claws pretty deep
into page reclaim, but I guess that is to be expected if we want
to increase readahead smarts much more.

However, I'm hoping bits of that can be merged at a time, and
interfaces and page reclaim stuff can be discussed and the best
option taken. No such luck with these patches AFAIKS - simply
adding another level of page groups, and another level of
heuristics to the page allocator is going to hurt. By definition.
I do wonder why zones can't be used... though I'm sure there are
good reasons.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
