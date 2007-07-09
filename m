Message-ID: <4691FFDC.5020808@yahoo.com.au>
Date: Mon, 09 Jul 2007 19:29:00 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH] Use mmu_gather for fork() instead of flush_tlb_mm()
References: <1183952874.3388.349.camel@localhost.localdomain>	 <1183962981.5961.3.camel@localhost.localdomain>	 <1183963544.5961.6.camel@localhost.localdomain>	 <4691E64F.5070506@yahoo.com.au> <1183972349.5961.25.camel@localhost.localdomain>
In-Reply-To: <1183972349.5961.25.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm@kvack.org, Linux Kernel list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt wrote:
> On Mon, 2007-07-09 at 17:39 +1000, Nick Piggin wrote:
> 
> 
>>Would it be better off to start off with a new API for this? The
>>mmu gather I think is traditionally entirely for dealing with
>>page removal...
> 
> 
> It would be weird because the new API would mostly duplicate this one,
> and we would end up with duplicated hooks..

They could just #define one to the other though, there are only a small
number of them. Is there a downside to not making them distinct? i386
for example probably would just keep doing a tlb flush for fork and not
want to worry about touching the tlb gather stuff.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
