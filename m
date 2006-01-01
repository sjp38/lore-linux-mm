Subject: Re: [PATCH 6/9] clockpro-clockpro.patch
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20051231224021.GA5184@dmt.cnet>
References: <20051230223952.765.21096.sendpatchset@twins.localnet>
	 <20051230224312.765.58575.sendpatchset@twins.localnet>
	 <20051231224021.GA5184@dmt.cnet>
Content-Type: text/plain
Date: Sun, 01 Jan 2006 11:37:34 +0100
Message-Id: <1136111854.17853.77.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Christoph Lameter <christoph@lameter.com>, Wu Fengguang <wfg@mail.ustc.edu.cn>, Nick Piggin <npiggin@suse.de>, Marijn Meijles <marijn@bitpit.net>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sat, 2005-12-31 at 20:40 -0200, Marcelo Tosatti wrote:
> On Fri, Dec 30, 2005 at 11:43:34PM +0100, Peter Zijlstra wrote:
> > 
> > From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> 
> Peter,
> 
> I tried your "scan-shared.c" proggy which loops over 140M of a file
> using mmap (on a 128MB box). The number of loops was configured to "5".
> 
> The amount of major/minor pagefaults was exactly the same between
> vanilla and clockpro, isnt the clockpro algorithm supposed to be
> superior than LRU in such "sequential scan of MEMSIZE+1" cases?

yes it should, hmm, have to look at that then.

What should happen is that nr_cold_target should drop to the bare
minimum, which effectivly pins all hot pages and only rotates the few
cold pages.

> Oh well, to be sincere, I still haven't understood what makes CLOCK-Pro
> use inter reference distance instead of recency, given that its a simple
> CLOCK using reference bits (but with three clocks instead of one).
> 
> But thats probably just my ignorance, need to study more.

The reuse distance is in PG_test. Please see the clockpro-documentation
patch, which should explain this. If its still not clear after that let
me know, I'll be more verbose then.

-- 
Peter Zijlstra <a.p.zijlstra@chello.nl>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
