Subject: Re: [PATCH] mm: MADV_WILLNEED implementation for anonymous memory
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20080130144049.73596898.akpm@linux-foundation.org>
References: <1201714139.28547.237.camel@lappy>
	 <20080130144049.73596898.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Thu, 31 Jan 2008 09:44:00 +0100
Message-Id: <1201769040.28547.245.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: hugh@veritas.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de, riel@redhat.com, mztabzr@0pointer.de, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Wed, 2008-01-30 at 14:40 -0800, Andrew Morton wrote:
> On Wed, 30 Jan 2008 18:28:59 +0100
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> 
> > Implement MADV_WILLNEED for anonymous pages by walking the page tables and
> > starting asynchonous swap cache reads for all encountered swap pages.
> 
> Why cannot this use (a perhaps suitably-modified) make_pages_present()?

Because make_pages_present() relies on page faults to bring data in and
will thus wait for all data to be present before returning.

This solution is async; it will just issue a read for the requested
pages and moves on.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
