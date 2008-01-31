Subject: Re: [PATCH] mm: MADV_WILLNEED implementation for anonymous memory
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20080131011227.257b9437.akpm@linux-foundation.org>
References: <1201714139.28547.237.camel@lappy>
	 <20080130144049.73596898.akpm@linux-foundation.org>
	 <1201769040.28547.245.camel@lappy>
	 <20080131011227.257b9437.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Thu, 31 Jan 2008 10:35:18 +0100
Message-Id: <1201772118.28547.254.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: hugh@veritas.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de, riel@redhat.com, mztabzr@0pointer.de, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Thu, 2008-01-31 at 01:12 -0800, Andrew Morton wrote:

> Implementation-wise: make_pages_present() _can_ be converted to do this. 
> But it's a lot of patching, and the result will be a cleaner, faster and
> smaller core MM.  Whereas your approach is easy, but adds more code and
> leaves the old stuff slow-and-dirty.
> 
> Guess which approach is preferred? ;)

Ok, I'll look at using make_pages_present().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
