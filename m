Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 17D2D6B004F
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 00:15:45 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2C4Fges007161
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 12 Mar 2009 13:15:43 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E1C745DD7B
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 13:15:42 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6093845DD7D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 13:15:42 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F0D01DB8043
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 13:15:42 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C2328E08006
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 13:15:41 +0900 (JST)
Date: Thu, 12 Mar 2009 13:14:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 2/5] add softlimit to res_counter
Message-Id: <20090312131419.5250cdaf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090312041038.GF23583@balbir.in.ibm.com>
References: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090312095612.4a7758e1.kamezawa.hiroyu@jp.fujitsu.com>
	<20090312035444.GC23583@balbir.in.ibm.com>
	<20090312125839.3b01e20c.kamezawa.hiroyu@jp.fujitsu.com>
	<20090312041038.GF23583@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Mar 2009 09:40:38 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Correct me if I am wrong, but this boils down to checking if the top
> root is above it's soft limit? 

  Level_1    soft limit=400M
    Level_2  soft limit=200M
      Level_3  no soft limit
      Level_3  softlimit=100M
    Level_2  soft limit=200M
    Level_2  soft limit=200M

When checking Level3, we need to check Level_2 and Level_1.


> Instead of checking all the way up in
> the hierarchy, can't we do a conditional check for
> 
>         c->parent == NULL && (c->softlimit < c->usage)
> 
> BTW, I would prefer to split the word softlimit to soft_limit, it is
> more readable that way.
> 
Ok, it will give me tons of HUNK but will do ;)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
