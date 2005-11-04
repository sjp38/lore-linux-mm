Subject: Re: [PATCH]: Clean up of __alloc_pages
From: Rohit Seth <rohit.seth@intel.com>
In-Reply-To: <4366C188.5090607@yahoo.com.au>
References: <20051028183326.A28611@unix-os.sc.intel.com>
	 <4362DF80.3060802@yahoo.com.au>
	 <1130792107.4853.24.camel@akash.sc.intel.com>
	 <4366C188.5090607@yahoo.com.au>
Content-Type: text/plain
Date: Fri, 04 Nov 2005 10:15:08 -0800
Message-Id: <1131128108.27563.11.camel@akash.sc.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2005-11-01 at 12:14 +1100, Nick Piggin wrote:
> Rohit Seth wrote:
> > On Sat, 2005-10-29 at 12:33 +1000, Nick Piggin wrote:
> 
> >>If you don't do this, then a GFP_HIGH allocator can allocate right
> >>down to its limit before it kicks kswapd, then it either will fail or
> >>will have to do direct reclaim.
> >>
> > 
> > 
> > You are right if there are only GFP_HIGH requests coming in then the
> > allocation will go down to (min - min/2) before kicking in kswapd.
> > Though if the requester is not ready to wait, there is another good shot
> > at allocation succeed before we get into direct reclaim (and this is
> > happening based on can_try_harder flag).
> > 
> 
> Still, it is a change in behaviour that I would rather not introduce
> with a cleanup patch (and is something we don't want to introduce anyway).
> 
> So if you could fix that up it would be good.
> 

Nick, sorry for not responding earlier.  

I agree that it is slight change in behavior from original.  I doubt
though it will impact any one in any negative way (may be for some
higher order allocations if at all). On a little positive side, less
frequent calls to kswapd for some cases and clear up the code a little
bit.

But I really don't want to get stuck here. The pcp traversal and
flushing is where I want to go next.  

Thanks,
-rohit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
