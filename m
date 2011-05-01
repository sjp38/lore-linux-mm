Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C9FF6900001
	for <linux-mm@kvack.org>; Sun,  1 May 2011 02:06:06 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 50EB83EE0AE
	for <linux-mm@kvack.org>; Sun,  1 May 2011 15:06:03 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A41445DE93
	for <linux-mm@kvack.org>; Sun,  1 May 2011 15:06:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 225E445DE91
	for <linux-mm@kvack.org>; Sun,  1 May 2011 15:06:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 15F691DB803B
	for <linux-mm@kvack.org>; Sun,  1 May 2011 15:06:03 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D73E11DB802F
	for <linux-mm@kvack.org>; Sun,  1 May 2011 15:06:02 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/7] memcg: add high/low watermark to res_counter
In-Reply-To: <20110429133313.GB306@tiehlicka.suse.cz>
References: <20110425182849.ab708f12.kamezawa.hiroyu@jp.fujitsu.com> <20110429133313.GB306@tiehlicka.suse.cz>
Message-Id: <20110501150410.75D2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun,  1 May 2011 15:06:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>

> On Mon 25-04-11 18:28:49, KAMEZAWA Hiroyuki wrote:
> > There are two watermarks added per-memcg including "high_wmark" and "low_wmark".
> > The per-memcg kswapd is invoked when the memcg's memory usage(usage_in_bytes)
> > is higher than the low_wmark. Then the kswapd thread starts to reclaim pages
> > until the usage is lower than the high_wmark.
> 
> I have mentioned this during Ying's patchsets already, but do we really
> want to have this confusing naming? High and low watermarks have
> opposite semantic for zones.

Can you please clarify this? I feel it is not opposite semantics.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
