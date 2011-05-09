Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A7DDA6B0012
	for <linux-mm@kvack.org>; Mon,  9 May 2011 08:49:22 -0400 (EDT)
Date: Mon, 9 May 2011 14:49:17 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/7] memcg: add high/low watermark to res_counter
Message-ID: <20110509124916.GD4273@tiehlicka.suse.cz>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110509101817.GB16531@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>

On Mon 09-05-11 12:18:17, Johannes Weiner wrote:
> On Mon, May 09, 2011 at 04:10:47PM +0900, KAMEZAWA Hiroyuki wrote:
[...]
> What I am wondering, though: we already have a limit to push back
> memcgs when we need memory, the soft limit.  The 'need for memory' is
> currently defined as global memory pressure, which we know may be too
> late.  The problem is not having no limit, the problem is that we want
> to control the time of when this limit is enforced.  So instead of
> adding another limit, could we instead add a knob like
> 
> 	memory.force_async_soft_reclaim
> 
> that asynchroneously pushes back to the soft limit instead of having
> another, separate limit to configure?

Sound much better than a separate watermark to me. I am just wondering
how we would implement soft unlimited groups with background reclaim.
Btw. is anybody relying on such configuration? To me it sounds like
something should be either limited or unlimited and making it half of
both is hacky.

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
