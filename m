Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1310E6B005D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 21:56:51 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6A2HqXI000906
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 10 Jul 2009 11:17:52 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C14045DE6E
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 11:17:52 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A82145DE60
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 11:17:52 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F6FE1DB803A
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 11:17:52 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A13281DB803B
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 11:17:48 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/5] OOM analysis helper patch series v2
In-Reply-To: <20090710083407.17BE.A69D9226@jp.fujitsu.com>
References: <alpine.DEB.1.00.0907091502450.25351@mail.selltech.ca> <20090710083407.17BE.A69D9226@jp.fujitsu.com>
Message-Id: <20090710111241.17DE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 10 Jul 2009 11:17:47 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Li, Ming Chun" <macli@brc.ubc.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > On Thu, 9 Jul 2009, Li, Ming Chun wrote:
> > 
> > I am applying the patch series to 2.6.31-rc2.
> 
> hm, maybe I worked on a bit old tree. I will check latest linus tree again
> today.
> 
> thanks.

I checked my patch on 2.6.31-rc2. but I couldn't reproduce your problem.

But, I recognize my fault.
This patch series depend on "[PATCH] Makes slab pages field in show_free_areas() separate two field"
patch. (it was posted at "Jul 30").
Can you please apply it at first?

Or, can you use mmotm tree?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
