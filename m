Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 245D86B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 03:32:58 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAU8WtMW003303
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 30 Nov 2010 17:32:55 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 58A6245DE7A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 17:32:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3046B45DE70
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 17:32:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 12E7DE38004
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 17:32:55 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B644C1DB803F
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 17:32:54 +0900 (JST)
Date: Tue, 30 Nov 2010 17:27:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] Add kswapd descriptor.
Message-Id: <20101130172710.38de418b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTikXzSx3Sjqb1NYZB-EJ76N-UbmiwTo=eOtSOnaP@mail.gmail.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
	<1291099785-5433-2-git-send-email-yinghan@google.com>
	<20101130160838.4c66febf.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikXzSx3Sjqb1NYZB-EJ76N-UbmiwTo=eOtSOnaP@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Ying Han <yinghan@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Nov 2010 17:15:37 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Ideally, I hope we unify global and memcg of kswapd for easy
> maintainance if it's not a big problem.
> When we make patches about lru pages, we always have to consider what
> I should do for memcg.
> And when we review patches, we also should consider what the patch is
> missing for memcg.
> It makes maintainance cost big. Of course, if memcg maintainers is
> involved with all patches, it's no problem as it is.
> 
I know it's not. But thread control of kswapd will not have much merging point.
And balance_pgdat() is fully replaced in patch/3. The effort for merging seems
not big.

> If it is impossible due to current kswapd's spaghetti, we can clean up
> it first. I am not sure whether my suggestion make sense or not.

make sense.

> Kame can know it much rather than me. But please consider such the voice.

Unifying is ok in general but this patch seems uglier than imagined.
Implementing a simple memcg one and considering how-to-merge is a way.
But it's a long way.

For now. we have to check the design/function of patch before how beautiful it
is.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
