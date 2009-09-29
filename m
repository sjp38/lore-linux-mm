Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5CEA46B005A
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 03:08:35 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8T7R0gJ010766
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 29 Sep 2009 16:27:01 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A40C145DE51
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 16:27:00 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 850E245DE4F
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 16:27:00 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FD891DB8038
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 16:27:00 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id DFC371DB8037
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 16:26:56 +0900 (JST)
Date: Tue, 29 Sep 2009 16:24:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] memcg: some modification to softlimit under
 hierarchical memory reclaim.
Message-Id: <20090929162445.f675acaf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090929162122.f79159fc.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090929150141.0e672290.kamezawa.hiroyu@jp.fujitsu.com>
	<20090929061132.GA498@balbir.in.ibm.com>
	<20090929162122.f79159fc.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 29 Sep 2009 16:21:22 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 29 Sep 2009 11:41:32 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-09-29 15:01:41]:
> > 
> > > No major changes in this patch for 3 weeks.
> > > While testing, I found a few css->refcnt bug in softlimit.(and posted patches)
> > > But it seems no more (easy) ones.
> > >
> > 
> > Kamezawa-San, this worries me, could you please confirm if you are
> > able to see this behaviour without your patches applied as well?
> 
> will try just with BUG_ON() for css->refcnt patch.
> But it happend only once even with my patch set.
> I found the potential bug by review. I checked all css_get/put/tryget
> and it's an only candidates.

Ah, but I never deny this pactch's influence.

-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
