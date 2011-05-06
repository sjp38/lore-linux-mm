Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CC28A6B0023
	for <linux-mm@kvack.org>; Fri,  6 May 2011 01:36:41 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C0F563EE0C1
	for <linux-mm@kvack.org>; Fri,  6 May 2011 14:36:38 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A2ABA45DE96
	for <linux-mm@kvack.org>; Fri,  6 May 2011 14:36:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8709845DE94
	for <linux-mm@kvack.org>; Fri,  6 May 2011 14:36:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F6A0E18004
	for <linux-mm@kvack.org>; Fri,  6 May 2011 14:36:38 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 35026E08004
	for <linux-mm@kvack.org>; Fri,  6 May 2011 14:36:38 +0900 (JST)
Date: Fri, 6 May 2011 14:30:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/7] memcg: add high/low watermark to res_counter
Message-Id: <20110506143000.7151eab6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110502090741.GP6547@balbir.in.ibm.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110425182849.ab708f12.kamezawa.hiroyu@jp.fujitsu.com>
	<20110502090741.GP6547@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>

On Mon, 2 May 2011 14:37:41 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2011-04-25 18:28:49]:
		res_counter_set_high_wmark_limit(&mem->res, limit);
> > +	} else {
> > +		u64 low_wmark, high_wmark, low_distance;
> > +		if (mem->high_wmark_distance <= HILOW_DISTANCE)
> > +			low_distance = mem->high_wmark_distance / 2;
> > +		else
> > +			low_distance = HILOW_DISTANCE;
> > +		if (low_distance < PAGE_SIZE * 2)
> > +			low_distance = PAGE_SIZE * 2;
> > +
> > +		low_wmark = limit - low_distance;
> > +		high_wmark = limit - mem->high_wmark_distance;
> > +
> > +		res_counter_set_low_wmark_limit(&mem->res, low_wmark);
> > +		res_counter_set_high_wmark_limit(&mem->res, high_wmark);
> > +	}
> > +}
> > +
> 
> I've not seen the documentation patch, but it might be good to have
> some comments with what to expect the watermarks to be and who sets up
> up high_wmark_distance. 
> 

I'll refine these namings.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
