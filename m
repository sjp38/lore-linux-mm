Message-ID: <436AAE5E.6010609@yahoo.com.au>
Date: Fri, 04 Nov 2005 11:42:06 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
References: <4366C559.5090504@yahoo.com.au><20051101135651.GA8502@elte.hu><1130854224.14475.60.camel@localhost><20051101142959.GA9272@elte.hu><1130856555.14475.77.camel@localhost><20051101150142.GA10636@elte.hu><1130858580.14475.98.camel@localhost><20051102084946.GA3930@elte.hu><436880B8.1050207@yahoo.com.au><1130923969.15627.11.camel@localhost><43688B74.20002@yahoo.com.au><255360000.1130943722@[10.10.2.4]><4369824E.2020407@yahoo.com.au><306020000.1131032193@[10.10.2.4]><1131032422.2839.8.camel@laptopd505.fenrus.org><Pine.LNX.4.64.0511030747450.27915@g5.osdl.org><Pine.LNX.4.58.0511031613560.3571@skynet> <Pine.LNX.4.64.0511030842050.27915@g5.osdl.org><309420000.1131036740@[10.10.2.4]><Pine.LNX.4.64.0511030918110.27915@g5.osdl.org><311050000.1131040276@[10.10.2.4]><314040000.1131043735@[10.10.2.4]><Pine.LNX.4.64.0511031102590.27915@g5.osdl.org> <43370000.1131057466@flay> <Pine.LNX.4.64.0511031459110.27915@g5.osdl.org> <53860000.1131061176@flay>
In-Reply-To: <53860000.1131061176@flay>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Linus Torvalds <torvalds@osdl.org>, Mel Gorman <mel@csn.ul.ie>, Arjan van de Ven <arjan@infradead.org>, Dave Hansen <haveblue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>, Arjan van de Ven <arjanv@infradead.org>
List-ID: <linux-mm.kvack.org>

Martin J. Bligh wrote:
>>Ahh, you're right, there's a totally separate watermark for highmem.
>>
>>I think I even remember this. I may even be responsible. I know some of 
>>our less successful highmem balancing efforts in the 2.4.x timeframe had 
>>serious trouble when they ran out of highmem, and started pruning lowmem 
>>very very aggressively. Limiting the highmem water marks meant that it 
>>wouldn't do that very often.
>>
>>I think your patch may in fact be fine, but quite frankly, it needs 
>>testing under real load with highmem.
>>

I'd prefer not. The reason is that it increases the "min"
watermark, which only gets used basically by GFP_ATOMIC and
PF_MEMALLOC allocators - neither of which are likely to want
highmem.

Also, I don't think anybody cares about higher order highmem
allocations. At least the patches in this thread:
http://marc.theaimsgroup.com/?l=linux-kernel&m=113082256231168&w=2

Should be applied before this. However they also need more
testing so I'll be sending them to Andrew first.

Patch 2 does basically the same thing as your patch, without
increasing the min watermark.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
