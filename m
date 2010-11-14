Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 77CB68D0001
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 00:07:12 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAE579mt001533
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 14 Nov 2010 14:07:10 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 52B2C45DE7D
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:07:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1072545DE4D
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:07:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E04E81DB8040
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:07:08 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DA1C1DB803B
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:07:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 55 of 66] select CONFIG_COMPACTION if TRANSPARENT_HUGEPAGE enabled
In-Reply-To: <20101109211145.GB6809@random.random>
References: <20101109151756.BC7B.A69D9226@jp.fujitsu.com> <20101109211145.GB6809@random.random>
Message-Id: <20101111091220.9941.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Sun, 14 Nov 2010 14:07:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

> On Tue, Nov 09, 2010 at 03:20:33PM +0900, KOSAKI Motohiro wrote:
> > > From: Andrea Arcangeli <aarcange@redhat.com>
> > > 
> > > With transparent hugepage support we need compaction for the "defrag" sysfs
> > > controls to be effective.
> > > 
> > > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > > ---
> > > 
> > > diff --git a/mm/Kconfig b/mm/Kconfig
> > > --- a/mm/Kconfig
> > > +++ b/mm/Kconfig
> > > @@ -305,6 +305,7 @@ config NOMMU_INITIAL_TRIM_EXCESS
> > >  config TRANSPARENT_HUGEPAGE
> > >  	bool "Transparent Hugepage Support"
> > >  	depends on X86 && MMU
> > > +	select COMPACTION
> > >  	help
> > >  	  Transparent Hugepages allows the kernel to use huge pages and
> > >  	  huge tlb transparently to the applications whenever possible.
> > 
> > I dislike this. THP and compaction are completely orthogonal. I think 
> > you are talking only your performance recommendation. I mean I dislike
> > Kconfig 'select' hell and I hope every developers try to avoid it as 
> > far as possible.
> 
> At the moment THP hangs the system if COMPACTION isn't selected
> (please try yourself if you don't believe), as without COMPACTION
> lumpy reclaim wouldn't be entirely disabled. So at the moment it's not
> orthogonal. When lumpy will be removed from the VM (like I tried
> multiple times to achieve) I can remove the select COMPACTION in
> theory, but then 99% of THP users would be still doing a mistake in
> disabling compaction, even if the mistake won't return in fatal
> runtime but just slightly degraded performance.

ok, I beleive you.
but please add this reason to the description.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
