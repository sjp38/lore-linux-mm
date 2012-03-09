Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 3801C6B007E
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 02:25:49 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4EB573EE0BC
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 16:25:47 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3627245DE55
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 16:25:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1879645DE4F
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 16:25:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D06241DB803B
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 16:25:46 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 72D091DB804B
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 16:25:46 +0900 (JST)
Date: Fri, 9 Mar 2012 16:23:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg: fix behavior of shard anon pages at task_move (Was
 Re: [PATCH v3 2/2] memcg: avoid THP split in task migration
Message-Id: <20120309162357.71c8c573.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120309150109.51ba8ea1.nishimura@mxp.nes.nec.co.jp>
References: <1330719189-20047-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1330719189-20047-2-git-send-email-n-horiguchi@ah.jp.nec.com>
	<20120309101658.8b36ce4f.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1203081816170.18242@eggly.anvils>
	<20120309122448.92931dc6.kamezawa.hiroyu@jp.fujitsu.com>
	<20120309150109.51ba8ea1.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Fri, 9 Mar 2012 15:01:09 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Fri, 9 Mar 2012 12:24:48 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > I'd rather delete than add code here!
> > > 
> > 
> > As a user, for Fujitsu, I believe it's insane to move task between cgroups.
> > So, I have no benefit from this code, at all.
> > Ok, maybe I'm not a stakeholder,here.
> > 
> I agree that moving tasks between cgroup is not a sane operation,
> users won't do it so frequently, but I cannot prevent that.
> That's why I implemented this feature.
> 
> > If users say all shared pages should be moved, ok, let's move.
> > But change of behavior should be documented and implemented in an independet
> > patch. CC'ed Nishimura-san, he implemetned this, a real user.
> > 
> To be honest, shared anon is not my concern. My concern is 
> shared memory(that's why, mapcount is not checked as for file pages.
> I assume all processes sharing the same shared memory will be moved together).
> So, it's all right for me to change the behavior for shared anon(or leave
> it as it is).
> 

Thank you for comment. Then, here is a patch.

Other opinions ?

==
