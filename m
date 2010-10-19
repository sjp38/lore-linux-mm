Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id AFEAC6B004A
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 20:57:31 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9J0vT3i032449
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 19 Oct 2010 09:57:29 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3AC0B45DE58
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 09:57:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EB99F45DE51
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 09:57:28 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B2C091DB804E
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 09:57:28 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 715FAE08001
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 09:57:28 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Deadlock possibly caused by too_many_isolated.
In-Reply-To: <20101018154137.90f5325f.akpm@linux-foundation.org>
References: <20101019093142.509d6947@notabene> <20101018154137.90f5325f.akpm@linux-foundation.org>
Message-Id: <20101019095144.A1B0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 19 Oct 2010 09:57:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Neil Brown <neilb@suse.de>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

> > I think there are two bugs here.
> > The raid1 bug that Torsten mentions is certainly real (and has been around
> > for an embarrassingly long time).
> > The bug that I identified in too_many_isolated is also a real bug and can be
> > triggered without md/raid1 in the mix.
> > So this is not a 'full fix' for every bug in the kernel :-), but it could
> > well be a full fix for this particular bug.
> > 
> 
> Can we just delete the too_many_isolated() logic?  (Crappy comment
> describes what the code does but not why it does it).

if my remember is correct, we got bug report that LTP may makes misterious
OOM killer invocation about 1-2 years ago. because, if too many parocess are in
reclaim path, all of reclaimable pages can be isolated and last reclaimer found
the system don't have any reclaimable pages and lead to invoke OOM killer.
We have strong motivation to avoid false positive oom. then, some discusstion
made this patch.

if my remember is incorrect, I hope Wu or Rik fix me.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
