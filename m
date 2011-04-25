Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 408C68D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 06:21:20 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2D0B83EE0BD
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 19:21:17 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E7F845DE95
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 19:21:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E945A45DE92
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 19:21:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D9DD0E08003
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 19:21:16 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A51391DB8038
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 19:21:16 +0900 (JST)
Date: Mon, 25 Apr 2011 19:14:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/7] memcg background reclaim , yet another one.
Message-Id: <20110425191437.d881ee68.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>

On Mon, 25 Apr 2011 18:25:29 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:


> 2) == hard limit 500M/ hi_watermark = 400M ==
> [root@rhel6-test hilow]# time cp ./tmpfile xxx
> 
> real    0m6.421s
> user    0m0.059s
> sys     0m2.707s
> 

When doing this, we see usage changes as
(sec) (bytes)
   0: 401408        <== cp start
   1: 98603008
   2: 262705152
   3: 433491968     <== wmark reclaim triggerd.
   4: 486502400
   5: 507748352
   6: 524189696     <== cp ends (and hit limits)
   7: 501231616
   8: 499511296
   9: 477118464
  10: 417980416     <== usage goes below watermark.
  11: 417980416
 .....

If we have dirty_ratio, this result will be some different.
(and flusher thread will work sooner...)


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
