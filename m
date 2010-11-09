Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 06C6E6B00BD
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 22:18:53 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oA93IpZ6027628
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 9 Nov 2010 12:18:51 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E8A745DE4E
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 12:18:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 09EE545DE51
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 12:18:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DA1A21DB8055
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 12:18:50 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 708AC1DB8054
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 12:18:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 01 of 66] disable lumpy when compaction is enabled
In-Reply-To: <ca2fea6527833aad8adc.1288798056@v2.random>
References: <patchbomb.1288798055@v2.random> <ca2fea6527833aad8adc.1288798056@v2.random>
Message-Id: <20101109121318.BC51.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  9 Nov 2010 12:18:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Compaction is more reliable than lumpy, and lumpy makes the system unusable
> when it runs.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -274,6 +274,7 @@ unsigned long shrink_slab(unsigned long 
>  static void set_lumpy_reclaim_mode(int priority, struct scan_control *sc,
>  				   bool sync)
>  {
> +#ifndef CONFIG_COMPACTION
>  	enum lumpy_mode mode = sync ? LUMPY_MODE_SYNC : LUMPY_MODE_ASYNC;
>  
>  	/*
> @@ -294,11 +295,14 @@ static void set_lumpy_reclaim_mode(int p
>  		sc->lumpy_reclaim_mode = mode;
>  	else
>  		sc->lumpy_reclaim_mode = LUMPY_MODE_NONE;
> +#endif
>  }

I'm talking very personal thing now. I'm usually testing both feature.
Then, runtime switching makes my happy :-)
However I don't know what are you and Mel talking and agree about this.
So, If many developer prefer this approach, I don't oppose anymore.

But, I bet almost all distro choose CONFIG_COMPACTION=y. then, lumpy code
will become nearly dead code. So, I like just kill than dead code. however
it is also only my preference. ;)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
