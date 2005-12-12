Message-ID: <439CF93D.5090207@yahoo.com.au>
Date: Mon, 12 Dec 2005 15:14:53 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC 1/6] Framework
References: <20051210005440.3887.34478.sendpatchset@schroedinger.engr.sgi.com> <20051210005445.3887.94119.sendpatchset@schroedinger.engr.sgi.com> <439CF2A2.60105@yahoo.com.au> <20051212035631.GX11190@wotan.suse.de>
In-Reply-To: <20051212035631.GX11190@wotan.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> On Mon, Dec 12, 2005 at 02:46:42PM +1100, Nick Piggin wrote:
> 
>>Christoph Lameter wrote:
>>
>>
>>>+/*
>>>+ * For use when we know that interrupts are disabled.
>>>+ */
>>>+static inline void __mod_zone_page_state(struct zone *zone, enum 
>>>zone_stat_item item, int delta)
>>>+{
>>
>>Before this goes through, I have a full patch to do similar for the
>>rest of the statistics, and which will make names consistent with what
>>you have (shouldn't be a lot of clashes though).
> 
> 
> I also have a patch to change them all to local_t, greatly simplifying
> it (e.g. the counters can be done inline then) 
> 

Cool. That is a patch that should go on top of mine, because most of
my patch is aimed at moving modifications under interrupts-off sections,
so you would then be able to use __local_xxx operations very easily for
most of the counters here.

However I'm still worried about the use of locals tripling the cacheline
size of a hot-path structure on some 64-bit architectures. Probably we
should get them to try to move to the atomic64 scheme before using
local_t here.

Nick

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
