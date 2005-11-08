Subject: Re: [PATCH]: Cleanup of __alloc_pages
From: Rohit Seth <rohit.seth@intel.com>
In-Reply-To: <43703EFB.1010103@yahoo.com.au>
References: <20051107174349.A8018@unix-os.sc.intel.com>
	 <20051107175358.62c484a3.akpm@osdl.org>
	 <1131416195.20471.31.camel@akash.sc.intel.com>
	 <43701FC6.5050104@yahoo.com.au> <20051107214420.6d0f6ec4.pj@sgi.com>
	 <43703EFB.1010103@yahoo.com.au>
Content-Type: text/plain
Date: Tue, 08 Nov 2005 10:17:56 -0800
Message-Id: <1131473876.2400.9.camel@akash.sc.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Paul Jackson <pj@sgi.com>, akpm@osdl.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2005-11-08 at 17:00 +1100, Nick Piggin wrote:

> 
> > However, I appreciate your preference to separate cleanup from semantic
> > change.  Perhaps this means leaving the ALLOC_CPUSET flag in your
> > cleanup patch, then one of us following on top of that with a patch to
> > simplify and fix the cpuset invocation semantics and a second cleanup
> > patch to remove ALLOC_CPUSET as a separate flag.
> > 
> 
> That would be good. I'll send off a fresh patch with the
> ALLOC_WATERMARKS fixed after Rohit gets around to looking over
> it.
> 

Nick, your changes have really come out good.  Thanks.  I think it is
definitely a good starting point as it maintains all of existing
behavior.

I guess now I can argue about why we should keep the watermark low for
GFP_HIGH ;-)

Paul, sorry for troubling you with those magic numbers again in the
original patch...

-rohit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
