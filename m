Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 66B506B0026
	for <linux-mm@kvack.org>; Tue, 17 May 2011 22:15:21 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 6161A3EE0BD
	for <linux-mm@kvack.org>; Wed, 18 May 2011 11:15:17 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 47AAD45DE95
	for <linux-mm@kvack.org>; Wed, 18 May 2011 11:15:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2580D45DE78
	for <linux-mm@kvack.org>; Wed, 18 May 2011 11:15:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1759EE18002
	for <linux-mm@kvack.org>; Wed, 18 May 2011 11:15:17 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D2F951DB8038
	for <linux-mm@kvack.org>; Wed, 18 May 2011 11:15:16 +0900 (JST)
Date: Wed, 18 May 2011 11:08:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] memcg: add memory.numastat api for numa statistics
Message-Id: <20110518110821.20c29c11.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTinA3osWTkngOoZQ22oXaFR82=17Zg@mail.gmail.com>
References: <1305671151-21993-1-git-send-email-yinghan@google.com>
	<1305671151-21993-2-git-send-email-yinghan@google.com>
	<20110518085258.98f07390.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinA3osWTkngOoZQ22oXaFR82=17Zg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Tue, 17 May 2011 18:40:23 -0700
Ying Han <yinghan@google.com> wrote:

> On Tue, May 17, 2011 at 4:52 PM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Tue, 17 May 2011 15:25:51 -0700
> > Ying Han <yinghan@google.com> wrote:
> >
> > > The new API exports numa_maps per-memcg basis. This is a piece of useful
> > > information where it exports per-memcg page distribution across real numa
> > > nodes.
> > >
> > > One of the usecase is evaluating application performance by combining
> > this
> > > information w/ the cpu allocation to the application.
> > >
> > > The output of the memory.numastat tries to follow w/ simiar format of
> > numa_maps
> > > like:
> > >
> > > <total pages> N0=<node 0 pages> N1=<node 1 pages> ...
> > >
> > > $ cat /dev/cgroup/memory/memory.numa_stat
> > > 292115 N0=36364 N1=166876 N2=39741 N3=49115
> > >
> > > Note: I noticed <total pages> is not equal to the sum of the rest of
> > counters.
> > > I might need to change the way get that counter, comments are welcomed.
> > >
> > > Signed-off-by: Ying Han <yinghan@google.com>
> >
> > Hmm, If I'm a user, I want to know file-cache is well balanced or where
> > Anon is
> > allocated from....Can't we have more precice one rather than
> > total(anon+file) ?
> >
> > So, I don't like this patch. Could you show total,anon,file at least ?
> >
> 
> Ok, then this is really becoming per-memcg numa_maps. Before I go ahead
> posting the next version, this is something we are looking for:
> 
> total=<total pages> N0=<node 0 pages> N1=<node 1 pages> ...
> anon=<total anon pages> N0=<node 0 pages> N1=<node 1 pages> ...
> file=<total file pages> N0=<node 0 pages> N1=<node 1 pages> ...
> 

seems good.

THanks,
-Kmae

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
