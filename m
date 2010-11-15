Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 389828D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 04:10:54 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAF9Aps2021683
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 15 Nov 2010 18:10:52 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 64D0545DE4F
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 18:10:51 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3714845DE51
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 18:10:51 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 089E2E08003
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 18:10:51 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A81E91DB803A
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 18:10:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: fadvise DONTNEED implementation (or lack thereof)
In-Reply-To: <1289810825.2109.469.camel@laptop>
References: <AANLkTim59Qx6TsvXnTBL5Lg6JorbGaqx3KsdBDWO04X9@mail.gmail.com> <1289810825.2109.469.camel@laptop>
Message-Id: <20101115180153.BF18.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Mon, 15 Nov 2010 18:10:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Ben Gamari <bgamari.foss@gmail.com>, linux-kernel@vger.kernel.org, rsync@lists.samba.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

> > I wonder what's the problem in Peter's patch 'drop behind'.
> > http://www.mail-archive.com/linux-kernel@vger.kernel.org/msg179576.html
> > 
> > Could anyone tell me why it can't accept upstream?
> 
> Read the thread, its quite clear nobody got convinced it was a good idea
> and wanted to fix the use-once policy, then Rik rewrote all of
> page-reclaim.

If my understand is correct, rsync touch data twice (for a hash calculation
and for a copy). then, currect used-once-heuristics seems still doesn't work.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
