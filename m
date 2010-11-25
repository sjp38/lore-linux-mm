Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3CB616B004A
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 12:36:12 -0500 (EST)
Date: Thu, 25 Nov 2010 18:35:18 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 17 of 66] add pmd mangling generic functions
Message-ID: <20101125173518.GR6118@random.random>
References: <patchbomb.1288798055@v2.random>
 <6022613f956ee326d9b6.1288798072@v2.random>
 <20101118125249.GN8135@csn.ul.ie>
 <AANLkTikhXS9ot27gS9OpRWbU9zjXns_D96DarZ1jOcR6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTikhXS9ot27gS9OpRWbU9zjXns_D96DarZ1jOcR6@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 09:32:36AM -0800, Linus Torvalds wrote:
> I dunno. Those macros are _way_ too big and heavy to be macros or
> inline functions. Why aren't pmdp_splitting_flush() etc just
> functions?

That's because ptep_clear_flush and everything else in that file named
with ptep_* and doing expensive tlb flushes was a macro.

> 
> There is no performance advantage to inlining them - the TLB flush is
> going to be expensive enough that there's no point in avoiding a
> function call. And that header file really does end up being _really_
> ugly.

I agree but to me it looks like your compliant applies to the current
include/asm-generic/pgtable.h. My changes that simply mirrors closely
the style of that file to avoid altering coding style just for the new
stuff. That is compact code that I'm not even sure if anybody is
using, most certainly x86 isn't using that code so the .text bloat
isn't a practical concern.

Do you like me to do a cleanup of the asm-generic/pgtable.h and move
the tlb flushes to lib/pgtable.c? (ideally the pgtable.o file should
be empty after the preprocessor runs on x86*)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
