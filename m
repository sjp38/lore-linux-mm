Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A32BD8D0039
	for <linux-mm@kvack.org>; Mon, 17 Jan 2011 10:10:44 -0500 (EST)
Date: Mon, 17 Jan 2011 15:33:45 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 13 of 66] export maybe_mkwrite
Message-ID: <20110117143345.GQ9506@random.random>
References: <patchbomb.1288798055@v2.random>
 <15324c9c30081da3a740.1288798068@v2.random>
 <4D344EAF.1080401@petalogix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4D344EAF.1080401@petalogix.com>
Sender: owner-linux-mm@kvack.org
To: Michal Simek <michal.simek@petalogix.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

Hi Michal,

On Mon, Jan 17, 2011 at 03:14:07PM +0100, Michal Simek wrote:
> Andrea Arcangeli wrote:
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > huge_memory.c needs it too when it fallbacks in copying hugepages into regular
> > fragmented pages if hugepage allocation fails during COW.
> > 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > Acked-by: Rik van Riel <riel@redhat.com>
> > Acked-by: Mel Gorman <mel@csn.ul.ie>
> 
> It wasn't good idea to do it. mm/memory.c is used only for system with 
> MMU. System without MMU are broken.
> 
> Not sure what the right fix is but anyway I think use one ifdef make 
> sense (git patch in attachment).

Can you show the build failure with CONFIG_MMU=n so I can understand
better? Other places in mm.h depends on pte_t/vm_area_struct/VM_WRITE
to be defined, if a system is without MMU nobody should call it
simply. Not saying your patch is wrong, but I'm trying to understand
how exactly it got broken and the gcc error would show it immediately.

This is only called by memory.o and huge_memory.o and they both are
built only if MMU=y.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
