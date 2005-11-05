Message-ID: <436BF606.3020805@yahoo.com.au>
Date: Sat, 05 Nov 2005 11:00:06 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH]: Clean up of __alloc_pages
References: <20051028183326.A28611@unix-os.sc.intel.com>	 <4362DF80.3060802@yahoo.com.au>	 <1130792107.4853.24.camel@akash.sc.intel.com>	 <4366C188.5090607@yahoo.com.au> <1131128108.27563.11.camel@akash.sc.intel.com>
In-Reply-To: <1131128108.27563.11.camel@akash.sc.intel.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rohit Seth <rohit.seth@intel.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rohit Seth wrote:

> 
> Nick, sorry for not responding earlier.  
> 

That's OK.

> I agree that it is slight change in behavior from original.  I doubt
> though it will impact any one in any negative way (may be for some
> higher order allocations if at all). On a little positive side, less
> frequent calls to kswapd for some cases and clear up the code a little
> bit.
> 

I really don't want a change of behaviour going in with this,
especially not one which I would want to revert anyway. But
don't get hung up with it - when you post your latest patch
I will make a patch for the changes I would like to see for it
and synch things up.

> But I really don't want to get stuck here. The pcp traversal and
> flushing is where I want to go next.  
> 

Sure, hope it goes well!

Nick

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
