Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9F5606B0044
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 22:30:10 -0500 (EST)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp04.au.ibm.com (8.14.3/8.13.1) with ESMTP id nBF3Qm4D026865
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 14:26:48 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBF3Q8MU1163290
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 14:26:10 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBF3U3dm014985
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 14:30:03 +1100
Date: Tue, 15 Dec 2009 09:00:00 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mmotm 0/8] memcg: move charge at task migration (14/Dec)
Message-ID: <20091215033000.GD6036@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20091214151748.bf9c4978.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20091214151748.bf9c4978.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

* nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2009-12-14 15:17:48]:

> Hi.
> 
> These are current patches of my move-charge-at-task-migration feature.
> 
> * They have not been mature enough to be merged into linus tree yet. *
> 
> Actually, there is a NULL pointer dereference BUG, which I found in my stress
> test after about 40 hours running and I'm digging now.
> I post these patches just to share my current status.
>
Could this be because of the css_get() and css_put() changes from the
previous release?

 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
