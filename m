Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CA4F86B0012
	for <linux-mm@kvack.org>; Thu, 12 May 2011 23:10:03 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E25853EE0BC
	for <linux-mm@kvack.org>; Fri, 13 May 2011 12:09:59 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C27A945DE9D
	for <linux-mm@kvack.org>; Fri, 13 May 2011 12:09:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A918645DE95
	for <linux-mm@kvack.org>; Fri, 13 May 2011 12:09:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9910FE18006
	for <linux-mm@kvack.org>; Fri, 13 May 2011 12:09:59 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 56D431DB803B
	for <linux-mm@kvack.org>; Fri, 13 May 2011 12:09:59 +0900 (JST)
Date: Fri, 13 May 2011 12:03:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/7] memcg async reclaim
Message-Id: <20110513120318.63ff7d0e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110512171725.d367980f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110510190216.f4eefef7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110511182844.d128c995.akpm@linux-foundation.org>
	<20110512103503.717f4a96.kamezawa.hiroyu@jp.fujitsu.com>
	<20110511205110.354fa05e.akpm@linux-foundation.org>
	<20110512132237.813a7c7f.kamezawa.hiroyu@jp.fujitsu.com>
	<20110512171725.d367980f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Thu, 12 May 2011 17:17:25 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 12 May 2011 13:22:37 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> I'll check what codes in vmscan.c or /mm affects memcg and post a
> required fix in step by step. I think I found some..
> 

After some tests, I doubt that 'automatic' one is unnecessary until
memcg's dirty_ratio is supported. And as Andrew pointed out,
total cpu consumption is unchanged and I don't have workloads which
shows me meaningful speed up.
But I guess...with dirty_ratio, amount of dirty pages in memcg is
limited and background reclaim can work enough without noise of
write_page() while applications are throttled by dirty_ratio.

Hmm, I'll study for a while but it seems better to start active soft limit,
(or some threshold users can set) first. 

Anyway, this work makes me to see vmscan.c carefully and I think I can
post some patches for fix, tunes.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
