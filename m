Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CDEDC6B0026
	for <linux-mm@kvack.org>; Sun,  8 May 2011 23:24:23 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 9AB4F3EE0C7
	for <linux-mm@kvack.org>; Mon,  9 May 2011 12:24:18 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 806B645DE4E
	for <linux-mm@kvack.org>; Mon,  9 May 2011 12:24:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C09645DE4F
	for <linux-mm@kvack.org>; Mon,  9 May 2011 12:24:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 610791DB803E
	for <linux-mm@kvack.org>; Mon,  9 May 2011 12:24:18 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 29A7E1DB802F
	for <linux-mm@kvack.org>; Mon,  9 May 2011 12:24:18 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/7] memcg: add high/low watermark to res_counter
In-Reply-To: <20110504085533.GB1375@tiehlicka.suse.cz>
References: <BANLkTi=ZNWG97XgTGoK6moHds4MTQHXAHg@mail.gmail.com> <20110504085533.GB1375@tiehlicka.suse.cz>
Message-Id: <20110509122601.3AD6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  9 May 2011 12:24:16 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>

> On Wed 04-05-11 12:55:19, KOSAKI Motohiro wrote:
> > >> Ah, right. So, do you have an alternative idea?
> > >
> > > Why cannot we just keep the global reclaim semantic and make it free
> > > memory (hard_limit - usage_in_bytes) based with low limit as the trigger
> > > for reclaiming?
> > 
> > Because it's not free memory. 
> 
> In some sense it is because it defines the available memory for a group.
> 
> > the cgroup doesn't reach a limit. but....
> 
> Same way how we do not get down to no free memory (due to reserves
> etc.). Or am I missing something.

Of cource, it's possible. The only two problem are 1) need much much trivial
rewrite exist code and 2) naming issue (it's not _free_).

So, I'm going away from this discussion. ;-) I don't have strong opinion this.
I only wrote the current decision reason. I don't dislike your idea too.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
