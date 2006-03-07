From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] avoid atomic op on page free
Date: Tue, 7 Mar 2006 07:30:27 +0100
References: <20060307001015.GG32565@linux.intel.com> <20060306173941.4b5e0fc7.akpm@osdl.org> <20060307015229.GJ32565@linux.intel.com>
In-Reply-To: <20060307015229.GJ32565@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200603070730.27999.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@linux.intel.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tuesday 07 March 2006 02:52, Benjamin LaHaise wrote:

> Those 1-2 cycles are free if you look at how things get scheduled with the 
> execution of the surrounding code. I bet $20 that you can't find a modern 
> CPU where the cost is measurable (meaning something like a P4, Athlon).  
> If this level of cost for the common case is a concern, it's probably worth 
> making atomic_dec_and_test() inline for page_cache_release().  The overhead 
> of the function call and the PageCompound() test is probably more than what 
> we're talking about as you're increasing the cache footprint and actually 
> performing a write to memory.

The test should be essentially free at least on an out of order CPU. Not quite sure 
about in order though.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
