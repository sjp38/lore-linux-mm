Date: Sat, 31 Dec 2005 20:40:21 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH 6/9] clockpro-clockpro.patch
Message-ID: <20051231224021.GA5184@dmt.cnet>
References: <20051230223952.765.21096.sendpatchset@twins.localnet> <20051230224312.765.58575.sendpatchset@twins.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051230224312.765.58575.sendpatchset@twins.localnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Christoph Lameter <christoph@lameter.com>, Wu Fengguang <wfg@mail.ustc.edu.cn>, Nick Piggin <npiggin@suse.de>, Marijn Meijles <marijn@bitpit.net>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 30, 2005 at 11:43:34PM +0100, Peter Zijlstra wrote:
> 
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Peter,

I tried your "scan-shared.c" proggy which loops over 140M of a file
using mmap (on a 128MB box). The number of loops was configured to "5".

The amount of major/minor pagefaults was exactly the same between
vanilla and clockpro, isnt the clockpro algorithm supposed to be
superior than LRU in such "sequential scan of MEMSIZE+1" cases?

Oh well, to be sincere, I still haven't understood what makes CLOCK-Pro
use inter reference distance instead of recency, given that its a simple
CLOCK using reference bits (but with three clocks instead of one).

But thats probably just my ignorance, need to study more.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
