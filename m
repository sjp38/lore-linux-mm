Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E0C098D0005
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 01:20:38 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oA96KaoZ008973
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 9 Nov 2010 15:20:36 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 15AE145DE55
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 15:20:36 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E64F245DE53
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 15:20:35 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id AF6B11DB8067
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 15:20:35 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 610C81DB805E
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 15:20:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 55 of 66] select CONFIG_COMPACTION if TRANSPARENT_HUGEPAGE enabled
In-Reply-To: <89a62752012298bb500c.1288798110@v2.random>
References: <patchbomb.1288798055@v2.random> <89a62752012298bb500c.1288798110@v2.random>
Message-Id: <20101109151756.BC7B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  9 Nov 2010 15:20:33 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> With transparent hugepage support we need compaction for the "defrag" sysfs
> controls to be effective.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -305,6 +305,7 @@ config NOMMU_INITIAL_TRIM_EXCESS
>  config TRANSPARENT_HUGEPAGE
>  	bool "Transparent Hugepage Support"
>  	depends on X86 && MMU
> +	select COMPACTION
>  	help
>  	  Transparent Hugepages allows the kernel to use huge pages and
>  	  huge tlb transparently to the applications whenever possible.

I dislike this. THP and compaction are completely orthogonal. I think 
you are talking only your performance recommendation. I mean I dislike
Kconfig 'select' hell and I hope every developers try to avoid it as 
far as possible.

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
