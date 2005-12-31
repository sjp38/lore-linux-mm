Date: Sat, 31 Dec 2005 05:03:20 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH 01/14] page-replace-single-batch-insert.patch
Message-ID: <20051231070320.GA9997@dmt.cnet>
References: <20051230223952.765.21096.sendpatchset@twins.localnet> <20051230224002.765.28812.sendpatchset@twins.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051230224002.765.28812.sendpatchset@twins.localnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Christoph Lameter <christoph@lameter.com>, Wu Fengguang <wfg@mail.ustc.edu.cn>, Nick Piggin <npiggin@suse.de>, Marijn Meijles <marijn@bitpit.net>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi Peter,

On Fri, Dec 30, 2005 at 11:40:24PM +0100, Peter Zijlstra wrote:
> 
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> 
> page-replace interface function:
>   __page_replace_insert()
> 
> This function inserts a page into the page replace data structure.
> 
> Unify the active and inactive per cpu page lists. For now provide insertion
> hints using the LRU specific page flags.

Unification of active and inactive per cpu page lists is a requirement
for CLOCK-Pro, right? 

Would be nicer to have unchanged functionality from vanilla VM
(including the active/inactive per cpu lists).

Happy new year! 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
