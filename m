Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A0AA06B00AE
	for <linux-mm@kvack.org>; Sun,  8 Mar 2009 19:47:01 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n28NkuEk007560
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 9 Mar 2009 08:46:57 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CDF4845DD75
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 08:46:56 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A974545DD72
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 08:46:56 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A47C81DB8046
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 08:46:56 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 546A11DB803E
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 08:46:56 +0900 (JST)
Date: Mon, 9 Mar 2009 08:45:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 3/3] memcg documenation soft limit (Yet Another
 One)
Message-Id: <20090309084536.d5b1c110.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <49B153A3.8090906@oracle.com>
References: <20090306092323.21063.93169.sendpatchset@localhost.localdomain>
	<20090306185440.66b92ca3.kamezawa.hiroyu@jp.fujitsu.com>
	<20090306193438.8084837d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090306193821.ca2fb628.kamezawa.hiroyu@jp.fujitsu.com>
	<49B153A3.8090906@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 06 Mar 2009 08:47:31 -0800
Randy Dunlap <randy.dunlap@oracle.com> wrote:
> > +	  Allowed priority level is 3-0 and 3 is the lowest.
> 
> 	Not very user friendly...
> 
Ok, then, 0(lowest) - 8(highest) in the next version.

-Kame

> > +	  If 0, this cgroup will not be target of softlimit.
> > +
> > +  At memory shortage of the system (or local node/zone), softlimit helps
> > +  kswapd(), a global memory recalim kernel thread, and inform victim cgroup
> 
>                                reclaim                    informs
> 
> > +  to be shrinked to kswapd.
> > +
> > +  Victim selection logic:
> > +  The kernel searches from the lowest priroty(3) up to the highest(1).
> 
>                                          priority                     0 ?? (from above)
> 
> > +  If it find a cgroup witch has memory larger than softlimit, steal memory
> 
>            finds         which
> 
> > +  from it.
> > +  If multiple cgroups are on the same priority, each cgroup wil be a
> 
>                                                                will
> 
> > +  victim in turn.
> >  
> >  6. Hierarchy support
> 
> 
> -- 
> ~Randy
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
