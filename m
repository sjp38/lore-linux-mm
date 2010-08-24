Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A33C56008DF
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 04:04:41 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7O84dQ6013118
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 24 Aug 2010 17:04:39 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 31ADD45DE50
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 17:04:39 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 197FD45DE4E
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 17:04:39 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id F37061DB8015
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 17:04:38 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id AB5BF1DB8013
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 17:04:38 +0900 (JST)
Date: Tue, 24 Aug 2010 16:59:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: towards I/O aware memcg v5
Message-Id: <20100824165926.3d069341.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100824074617.GI4684@balbir.in.ibm.com>
References: <20100820185552.426ff12e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100824074617.GI4684@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kamezawa.hiroyuki@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, 24 Aug 2010 13:16:17 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-08-20 18:55:52]:
> 
> > This is v5.
> > 
> > Sorry for delaying...but I had time for resetting myself and..several
> > changes are added. I think this version is simpler than v4.
> > 
> > Major changes from v4 is 
> >  a) added kernel/cgroup.c hooks again. (for b)
> >  b) make RCU aware. previous version seems dangerous in an extreme case.
> > 
> > Then, codes are updated. Most of changes are related to RCU.
> > 
> > Patch brief view:
> >  1. add hooks to kernel/cgroup.c for ID management.
> >  2. use ID-array in memcg.
> >  3. record ID to page_cgroup rather than pointer.
> >  4. make update_file_mapped to be RCU aware routine instead of spinlock.
> >  5. make update_file_mapped as general-purpose function.
> >
> 
> Thanks for being persistent, will review the patches with comments in
> the relevant patches. 
> 

Thank you. I may be able to post v6, tomorrow.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
