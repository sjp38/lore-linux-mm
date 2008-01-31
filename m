Date: Thu, 31 Jan 2008 01:12:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: MADV_WILLNEED implementation for anonymous memory
Message-Id: <20080131011227.257b9437.akpm@linux-foundation.org>
In-Reply-To: <1201769040.28547.245.camel@lappy>
References: <1201714139.28547.237.camel@lappy>
	<20080130144049.73596898.akpm@linux-foundation.org>
	<1201769040.28547.245.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: hugh@veritas.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de, riel@redhat.com, mztabzr@0pointer.de, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jan 2008 09:44:00 +0100 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> 
> On Wed, 2008-01-30 at 14:40 -0800, Andrew Morton wrote:
> > On Wed, 30 Jan 2008 18:28:59 +0100
> > Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > 
> > > Implement MADV_WILLNEED for anonymous pages by walking the page tables and
> > > starting asynchonous swap cache reads for all encountered swap pages.
> > 
> > Why cannot this use (a perhaps suitably-modified) make_pages_present()?
> 
> Because make_pages_present() relies on page faults to bring data in and
> will thus wait for all data to be present before returning.
> 
> This solution is async; it will just issue a read for the requested
> pages and moves on.
> 

I of course realise that.  I also realise that swapin_readahead() is
_supposed_ to make the difference moot.

There's something you guys aren't telling us.  Several things, actually. 
Please don't do that.



Implementation-wise: make_pages_present() _can_ be converted to do this. 
But it's a lot of patching, and the result will be a cleaner, faster and
smaller core MM.  Whereas your approach is easy, but adds more code and
leaves the old stuff slow-and-dirty.

Guess which approach is preferred? ;)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
