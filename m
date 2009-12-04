Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2FABC60021B
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 02:03:42 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB473bwq029713
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 4 Dec 2009 16:03:37 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id F1EA145DE4F
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 16:03:36 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D1AEE45DE4E
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 16:03:36 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id BEF161DB8037
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 16:03:36 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 75C571DB8038
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 16:03:36 +0900 (JST)
Date: Fri, 4 Dec 2009 16:00:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 0/7] memcg: move charge at task migration
 (04/Dec)
Message-Id: <20091204160042.3e5fd83d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091204155317.2d570a55.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091204144609.b61cc8c4.nishimura@mxp.nes.nec.co.jp>
	<20091204155317.2d570a55.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 4 Dec 2009 15:53:17 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Fri, 4 Dec 2009 14:46:09 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > In this version:
> >        |  252M  |  512M  |   1G
> >   -----+--------+--------+--------
> >    (1) |  0.15  |  0.30  |  0.60
> >   -----+--------+--------+--------
> >    (2) |  0.15  |  0.30  |  0.60
> >   -----+--------+--------+--------
> >    (3) |  0.22  |  0.44  |  0.89
> > 
> Nice !
> 

Ah. could you clarify...

 1. How is fork()/exit() affected by this move ?
 2. How long cpuset's migration-at-task-move requires ?
    I guess much longer than this.
 3. If need to reclaim memory for moving tasks, can this be longer ?
    If so, we may need some trick to release cgroup_mutex in task moving.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
