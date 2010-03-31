Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id CA9766B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 01:15:17 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2V5FD04017373
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 31 Mar 2010 14:15:14 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1EA3645DE52
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 14:15:13 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id F121045DE4E
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 14:15:12 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id BF5DFE18004
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 14:15:12 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F822EF8003
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 14:15:09 +0900 (JST)
Date: Wed, 31 Mar 2010 14:10:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #16
Message-Id: <20100331141035.523c9285.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <patchbomb.1269887833@v2.random>
References: <patchbomb.1269887833@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Mar 2010 20:37:13 +0200
Andrea Arcangeli <aarcange@redhat.com> wrote:

> Hello Andrew,
> 
> This is again against 2.6.34-rc1-mm1+ as before (I didn't find any newer -mm).
> 
> This removes PG_buddy and allows the PAE 32bit build with CONFIG_X86_PAT=y &&
> CONFIG_X86_PAE=y && CONFIG_SPARSEMEM =y and fixes two bits in memcg_compound.
> 
> Removing an unconditional unnecessary PG_ bitflag is overall a gain anyway
> (the added one is conditional to CONFIG_TRANSPARENT_HUGEPAGE which could be
> turned off on 32bit archs depending on which feature is more or less important
> to the user configuring the kernel).
> 
>         http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34-rc2-mm1/transparent_hugepage-16/
>         http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34-rc2-mm1/transparent_hugepage-16.gz
> 

Hmm, recently, I noticed that x86-64 has hugepage_size == pmd_size but we can't
assume that in generic. I know your code depends on x86-64 by CONFIG.
Can this implementation be enhanced for various hugepage in generic archs ?
I doubt based-on-pmd approach will get sucess in generic archs..

I'm sorry if you answered someone already.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
