Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 87F016B0022
	for <linux-mm@kvack.org>; Mon,  9 May 2011 19:56:10 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DDAEB3EE0B6
	for <linux-mm@kvack.org>; Tue, 10 May 2011 08:56:06 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C32BC45DF47
	for <linux-mm@kvack.org>; Tue, 10 May 2011 08:56:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AC06545DF4A
	for <linux-mm@kvack.org>; Tue, 10 May 2011 08:56:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9EB21E08001
	for <linux-mm@kvack.org>; Tue, 10 May 2011 08:56:06 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 666B71DB8038
	for <linux-mm@kvack.org>; Tue, 10 May 2011 08:56:06 +0900 (JST)
Date: Tue, 10 May 2011 08:49:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/7] memcg: add high/low watermark to res_counter
Message-Id: <20110510084923.03a282f1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110509124916.GD4273@tiehlicka.suse.cz>
References: <BANLkTimmpHcSJuO_8+P=GjYf+wB=Nyq=4w@mail.gmail.com>
	<20110503082550.GD18927@tiehlicka.suse.cz>
	<BANLkTikZtOdzsnjH=43AegLCpYc6ecfKsg@mail.gmail.com>
	<20110504085851.GC1375@tiehlicka.suse.cz>
	<BANLkTinxuSaCEvN4_vB=uA1rdGUwCpovog@mail.gmail.com>
	<20110505065901.GC11529@tiehlicka.suse.cz>
	<20110506142834.90e0b363.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinEEzkpBeTdK9nP2DAxRZbH8Ve=xw@mail.gmail.com>
	<20110509161047.eb674346.kamezawa.hiroyu@jp.fujitsu.com>
	<20110509101817.GB16531@cmpxchg.org>
	<20110509124916.GD4273@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>

On Mon, 9 May 2011 14:49:17 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Mon 09-05-11 12:18:17, Johannes Weiner wrote:
> > On Mon, May 09, 2011 at 04:10:47PM +0900, KAMEZAWA Hiroyuki wrote:
> [...]
> > What I am wondering, though: we already have a limit to push back
> > memcgs when we need memory, the soft limit.  The 'need for memory' is
> > currently defined as global memory pressure, which we know may be too
> > late.  The problem is not having no limit, the problem is that we want
> > to control the time of when this limit is enforced.  So instead of
> > adding another limit, could we instead add a knob like
> > 
> > 	memory.force_async_soft_reclaim
> > 
> > that asynchroneously pushes back to the soft limit instead of having
> > another, separate limit to configure?
> 

Hmm, ok to me. 

> Sound much better than a separate watermark to me. I am just wondering
> how we would implement soft unlimited groups with background reclaim.
> Btw. is anybody relying on such configuration? To me it sounds like
> something should be either limited or unlimited and making it half of
> both is hacky.

I don't think of soft-unlimited configuration. I don't want to handle it
in some automatic way.

Anyway, I'll add
  - _automatic_ background reclaim against the limit of memory, which works
    regarless of softlimit.
  - An interface for force softlimit.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
