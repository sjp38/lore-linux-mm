Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 917656B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 19:30:45 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 329623EE0AE
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 09:30:44 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0EAE045DEB2
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 09:30:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EAE2045DE9E
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 09:30:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DB9301DB803E
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 09:30:43 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 93C1E1DB803B
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 09:30:43 +0900 (JST)
Date: Fri, 20 Jan 2012 09:29:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: remove unnecessary thp check at page stat
 accounting
Message-Id: <20120120092928.d6514341.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120119093410.GB13932@tiehlicka.suse.cz>
References: <20120119161445.b3a8a9d2.kamezawa.hiroyu@jp.fujitsu.com>
	<20120119093410.GB13932@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>

On Thu, 19 Jan 2012 10:34:10 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> On Thu 19-01-12 16:14:45, KAMEZAWA Hiroyuki wrote:
> > Thank you very much for reviewing previous RFC series.
> > This is a patch against memcg-devel and linux-next (can by applied without HUNKs).
> > 
> > ==
> > 
> > From 64641b360839b029bb353fbd95f7554cc806ed05 Mon Sep 17 00:00:00 2001
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Date: Thu, 12 Jan 2012 16:08:33 +0900
> > Subject: [PATCH] memcg: remove unnecessary thp check in mem_cgroup_update_page_stat()
> > 
> > commit 58b318ecf(memcg-devel)
> >     memcg: make mem_cgroup_split_huge_fixup() more efficient
> > removes move_lock_page_cgroup() in thp-split path.
> 
> I wouldn't refer to something which will change its commit id by its
> SHA. I guess the subject is sufficient. 

> Btw. do we really need to
> mention this? Is it just to make sure that this doesn't get merged
> withtout the mentioned patch?
> 

Hmm, ok. Yes, just informing this patch depends on that patch.




> > So, We do not have to check PageTransHuge in mem_cgroup_update_page_stat
> > and fallback into the locked accounting because both move charge and thp
> > split up are done with compound_lock so they cannot race. update vs.
> > move is protected by the mem_cgroup_stealed sufficiently.
> > 
> > PageTransHuge pages shouldn't appear in this code path currently because
> > we are tracking only file pages at the moment but later we are planning
> > to track also other pages (e.g. mlocked ones).
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Other than that
> Acked-by: Michal Hocko <mhocko@suse.cz>
> 
Thank you.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
