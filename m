Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id BA2716B00AD
	for <linux-mm@kvack.org>; Tue, 12 May 2009 20:32:31 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4D0Wx2N002269
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 13 May 2009 09:33:00 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D858245DD81
	for <linux-mm@kvack.org>; Wed, 13 May 2009 09:32:58 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 42B0645DD7E
	for <linux-mm@kvack.org>; Wed, 13 May 2009 09:32:58 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D2A991DB803B
	for <linux-mm@kvack.org>; Wed, 13 May 2009 09:32:57 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 437191DB8043
	for <linux-mm@kvack.org>; Wed, 13 May 2009 09:32:57 +0900 (JST)
Date: Wed, 13 May 2009 09:31:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/3] fix stale swap cache account leak  in memcg v7
Message-Id: <20090513093127.4dadac97.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090512095158.GB6351@balbir.in.ibm.com>
References: <20090512104401.28edc0a8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090512095158.GB6351@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mingo@elte.hu, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 12 May 2009 15:21:58 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > The patch set includes followng
> >  [1/3] add mem_cgroup_is_activated() function. which tell us memcg is _really_ used.
> >  [2/3] fix swap cache handling race by avoidng readahead.
> >  [3/3] fix swap cache handling race by check swapcount again.
> > 
> > Result is good under my test.
> 
> What was the result (performance data impact) of disabling swap
> readahead? Otherwise, this looks the most reasonable set of patches
> for this problem.
> 
I'll measure some and report it in the next post.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
