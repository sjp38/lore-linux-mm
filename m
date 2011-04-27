Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 62EAD9000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 23:16:12 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C63123EE0C7
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 12:16:08 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id ACE2D45DE5A
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 12:16:08 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 947EB45DE55
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 12:16:08 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 873EA1DB8042
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 12:16:08 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5352D1DB8044
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 12:16:08 +0900 (JST)
Date: Wed, 27 Apr 2011 12:09:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v2] fix get_scan_count for working well with small
 targets
Message-Id: <20110427120931.a993890f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110427105031.db203b95.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110426181724.f8cdad57.kamezawa.hiroyu@jp.fujitsu.com>
	<20110426135934.c1992c3e.akpm@linux-foundation.org>
	<20110427105031.db203b95.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, Ying Han <yinghan@google.com>

On Wed, 27 Apr 2011 10:50:31 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 26 Apr 2011 13:59:34 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > What about simply removing the nr_saved_scan logic and permitting small
> > scans?  That simplifies the code and I bet it makes no measurable
> > performance difference.
> > 
> 
> ok, v2 here. How this looks ?
> For memcg, I think I should add select_victim_node() for direct reclaim,
> then, we'll be tune big memcg using small memory on a zone case.
> 


Ah, sorry this v2 doesn't remove nr_saved_scan in reclaim_stat. ...
I will send v3.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
