Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 60B54900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 09:33:17 -0400 (EDT)
Date: Fri, 29 Apr 2011 15:33:13 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/7] memcg: add high/low watermark to res_counter
Message-ID: <20110429133313.GB306@tiehlicka.suse.cz>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
 <20110425182849.ab708f12.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110425182849.ab708f12.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>

On Mon 25-04-11 18:28:49, KAMEZAWA Hiroyuki wrote:
> There are two watermarks added per-memcg including "high_wmark" and "low_wmark".
> The per-memcg kswapd is invoked when the memcg's memory usage(usage_in_bytes)
> is higher than the low_wmark. Then the kswapd thread starts to reclaim pages
> until the usage is lower than the high_wmark.

I have mentioned this during Ying's patchsets already, but do we really
want to have this confusing naming? High and low watermarks have
opposite semantic for zones.

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
