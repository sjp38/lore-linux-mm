Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D8C886B004D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 22:02:32 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2C22UN3022743
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 12 Mar 2009 11:02:30 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id F18E145DE50
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 11:02:29 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C39B545DE5F
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 11:02:29 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 902381DB804E
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 11:02:29 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 13DC61DB803E
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 11:02:29 +0900 (JST)
Date: Thu, 12 Mar 2009 11:01:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 6/5] softlimit document
Message-Id: <20090312110107.c4749a8d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <49B86B3A.2050506@cn.fujitsu.com>
References: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090312100112.6f010cae.kamezawa.hiroyu@jp.fujitsu.com>
	<49B86B3A.2050506@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Mar 2009 09:54:02 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> > +    - memory.softlimit_priority.
> > +	- priority of this cgroup at softlimit reclaim.
> > +	  Allowed priority level is 3-0 and 3 is the lowest.
> > +	  If 0, this cgroup will not be target of softlimit.
> > +
> 
> Seems this document is the older one...
> 
Ouch..my merge miss...please ignore this 6/5.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
