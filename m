Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8FFAF8D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 10:20:06 -0500 (EST)
Date: Fri, 28 Jan 2011 09:20:02 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] Provide control over unmapped pages (v4)
In-Reply-To: <20110128165605.3cbe5208.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1101280917570.1194@router.home>
References: <20110125051003.13762.35120.stgit@localhost6.localdomain6> <20110125051015.13762.13429.stgit@localhost6.localdomain6> <AANLkTikHLw0Qg+odOB-bDtBSB-5UbTJ5ZOM-ZAdMqXgh@mail.gmail.com> <AANLkTi=qXsDjN5Jp4m3QMgVnckoAM7uE9_Hzn6CajP+c@mail.gmail.com>
 <AANLkTinfxXc04S9VwQcJ9thFff=cP=icroaiVLkN-GeH@mail.gmail.com> <20110128064851.GB5054@balbir.in.ibm.com> <AANLkTikw_j0JJVqEsj1xThoashiOARg+8BgcLKrvkV3U@mail.gmail.com> <20110128165605.3cbe5208.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, balbir@linux.vnet.ibm.com, linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Fri, 28 Jan 2011, KAMEZAWA Hiroyuki wrote:

> > > I see it as a tradeoff of when to check? add_to_page_cache or when we
> > > are want more free memory (due to allocation). It is OK to wakeup
> > > kswapd while allocating memory, somehow for this purpose (global page
> > > cache), add_to_page_cache or add_to_page_cache_locked does not seem
> > > the right place to hook into. I'd be open to comments/suggestions
> > > though from others as well.
>
> I don't like add hook here.
> AND I don't want to run kswapd because 'kswapd' has been a sign as
> there are memory shortage. (reusing code is ok.)
>
> How about adding new daemon ? Recently, khugepaged, ksmd works for
> managing memory. Adding one more daemon for special purpose is not
> very bad, I think. Then, you can do
>  - wake up without hook
>  - throttle its work.
>  - balance the whole system rather than zone.
>    I think per-node balance is enough...


I think we already have enough kernel daemons floating around. They are
multiplying in an amazing way. What would be useful is to map all
the memory management background stuff into a process. May call this memd
instead? Perhaps we can fold khugepaged into kswapd as well etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
