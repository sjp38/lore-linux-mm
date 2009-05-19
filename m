Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1F6D06B004D
	for <linux-mm@kvack.org>; Mon, 18 May 2009 22:56:48 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4J2vdKg024932
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 19 May 2009 11:57:40 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AD9A345DD74
	for <linux-mm@kvack.org>; Tue, 19 May 2009 11:57:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9034345DD72
	for <linux-mm@kvack.org>; Tue, 19 May 2009 11:57:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 878161DB8012
	for <linux-mm@kvack.org>; Tue, 19 May 2009 11:57:39 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 122C51DB8013
	for <linux-mm@kvack.org>; Tue, 19 May 2009 11:57:39 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] zone_reclaim_mode is always 0 by default
In-Reply-To: <20090519102634.4EB4.A69D9226@jp.fujitsu.com>
References: <20090518034907.GF5869@localhost> <20090519102634.4EB4.A69D9226@jp.fujitsu.com>
Message-Id: <20090519115645.4EB7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 19 May 2009 11:57:38 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, "Zhang, Yanmin" <yanmin.zhang@intel.com>
List-ID: <linux-mm.kvack.org>

nit fix.

> In general, the feature of workload depended don't fit default option.
> we can't know end-user run what workload anyway.
> 
> Fortunately (or Unfortunately), typical workload and machine size had

typical workload and machine size and remote node distance

> significant mutuality.
> Thus, the current default setting calculation had worked well in past days.
> 
> Now, it was breaked. What should we do?
> 
> 
> 
> Yanmin, We know 99% linux people use intel cpu and you are one of
> most hard repeated testing guy in lkml and you have much test.
> May I ask your tested machine and benchmark? 
> 
> if zone_reclaim=0 tendency workload is much than zone_reclaim=1 tendency workload,
>  we can drop our afraid and we would prioritize your opinion, of cource.
> 
> thanks.
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
