Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B47666B005A
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 03:05:15 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8T7NbXK005857
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 29 Sep 2009 16:23:37 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 459F145DE4F
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 16:23:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 26EAE45DE4D
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 16:23:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 10C861DB803A
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 16:23:37 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C50071DB803E
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 16:23:33 +0900 (JST)
Date: Tue, 29 Sep 2009 16:21:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] memcg: some modification to softlimit under
 hierarchical memory reclaim.
Message-Id: <20090929162122.f79159fc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090929061132.GA498@balbir.in.ibm.com>
References: <20090929150141.0e672290.kamezawa.hiroyu@jp.fujitsu.com>
	<20090929061132.GA498@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 29 Sep 2009 11:41:32 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-09-29 15:01:41]:
> 
> > No major changes in this patch for 3 weeks.
> > While testing, I found a few css->refcnt bug in softlimit.(and posted patches)
> > But it seems no more (easy) ones.
> >
> 
> Kamezawa-San, this worries me, could you please confirm if you are
> able to see this behaviour without your patches applied as well?

will try just with BUG_ON() for css->refcnt patch.
But it happend only once even with my patch set.
I found the potential bug by review. I checked all css_get/put/tryget
and it's an only candidates.

> I am doing some more stress tests on my side.
>  
"a few" includes my patch and Nishimura-san's patch for refcnt
which fixes css->refcnt leak. Which are already in -rc.

As I said (in merge plan), I have some concerns on softlimit. But it's
not from softlimit code, but from memcg's nature and complication especially
with hierarchy. These 2 years history shows there are tons of race condition.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
