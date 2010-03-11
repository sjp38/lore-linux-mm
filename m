Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8E1506B0087
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 18:56:26 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2BNuOuK009227
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 12 Mar 2010 08:56:25 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 276F945DE61
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 08:56:24 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 00E7945DE55
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 08:56:24 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C18D71DB8044
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 08:56:23 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 61FD41DB8041
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 08:56:23 +0900 (JST)
Date: Fri, 12 Mar 2010 08:52:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 0/5] memcg: per cgroup dirty limit (v6)
Message-Id: <20100312085244.98e48991.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100311232708.GE2427@linux>
References: <1268175636-4673-1-git-send-email-arighi@develer.com>
	<20100311093913.07c9ca8a.kamezawa.hiroyu@jp.fujitsu.com>
	<20100311101726.f58d24e9.kamezawa.hiroyu@jp.fujitsu.com>
	<1268298865.5279.997.camel@twins>
	<20100311182500.0f3ba994.kamezawa.hiroyu@jp.fujitsu.com>
	<20100311150307.GC29246@redhat.com>
	<20100311232708.GE2427@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <arighi@develer.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Mar 2010 00:27:09 +0100
Andrea Righi <arighi@develer.com> wrote:

> On Thu, Mar 11, 2010 at 10:03:07AM -0500, Vivek Goyal wrote:

> > I am still setting up the system to test whether we see any speedup in
> > writeout of large files with-in a memory cgroup with small memory limits.
> > I am assuming that we are expecting a speedup because we will start
> > writeouts early and background writeouts probably are faster than direct
> > reclaim?
> 
> mmh... speedup? I think with a large file write + reduced dirty limits
> you'll get a more uniform write-out (more frequent small writes),
> respect to few and less frequent large writes. The system will be more
> reactive, but I don't think you'll be able to see a speedup in the large
> write itself.
> 
Ah, sorry. I misunderstood something. But it's depends on dirty_ratio param.
If
	background_dirty_ratio = 5
	dirty_ratio	       = 100
under 100M cgroup, I think background write-out will be a help.
(nonsense ? ;)

And I wonder make -j can get better number....Hmm.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
