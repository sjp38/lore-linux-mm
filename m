Message-ID: <44DFF11C.406@yahoo.com.au>
Date: Mon, 14 Aug 2006 13:42:20 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: rename *MEMALLOC flags
References: <20060812141415.30842.78695.sendpatchset@lappy>	<20060812141445.30842.47336.sendpatchset@lappy>	<44DDE8B6.8000900@garzik.org>	<1155395201.13508.44.camel@lappy>	<44DFBEA3.5070305@google.com> <20060813180054.65201239.pj@sgi.com>
In-Reply-To: <20060813180054.65201239.pj@sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Daniel Phillips <phillips@google.com>, a.p.zijlstra@chello.nl, jeff@garzik.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, indan@nul.nu, johnpol@2ka.mipt.ru, riel@redhat.com, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

Paul Jackson wrote:
> Daniel wrote:
> 
>>Inventing a new name for an existing thing is very poor taste on grounds of
>>grepability alone.
> 
> 
> I wouldn't say 'very poor taste' -- just something that should be
> done infrequently, with good reason, and with reasonable concensus,
> especially from the key maintainers in the affected area.
> 
> Good names are good taste, in my book.  But stable naming is good too.
> 
> I wonder what Nick thinks of this?  Looks like he added
> __GFP_NOMEMALLOC a year ago, following the naming style of PF_MEMALLOC.
> 
> I added him to the cc list.
> 

__GFP_NOMEMALLOC was added to prevent mempool backed allocations from
accessing the emergency reserve. Because that would just shift deadlocks
from mempool "safe" sites to those which have not been converted.

PF_MEMALLOC is a good name: PF_MEMALLOC says that the task is currently
allocating memory. It does not say anything about the actual allocator
implementation details to handle this (1. don't recurse into reclaim; 2.
allow access to reserves), but that is a good thing.

__GFP_NOMEMALLOC and __GFP_MEMALLOC are poorly named (I take the blame).
It isn't that the task is suddenly no longer allocating in the context
of an allocation, it is just that you want to allow or deny access to
the reserve.

__GFP_NOMEMALLOC should be something like __GFP_EMERG_NEVER and
__GFP_MEMALLOC should be _ALWAYS. Or something like that.

NOMEMALLOC is specific enough that I don't mind a rename at this stage.
Renaming PF_MEMALLOC would be wrong, however.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
