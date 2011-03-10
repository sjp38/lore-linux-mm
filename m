Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5D56F8D003A
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 18:52:23 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 548363EE0C0
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 08:52:19 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3843845DE58
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 08:52:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1EAD445DE4D
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 08:52:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A806E08004
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 08:52:19 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CA0CDE08002
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 08:52:18 +0900 (JST)
Date: Fri, 11 Mar 2011 08:45:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v4] memcg: fix leak on wrong LRU with FUSE
Message-Id: <20110311084551.883c8aeb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110310142029.5d108e37.akpm@linux-foundation.org>
References: <20110308135612.e971e1f3.kamezawa.hiroyu@jp.fujitsu.com>
	<20110308181832.6386da5f.nishimura@mxp.nes.nec.co.jp>
	<20110309150750.d570798c.kamezawa.hiroyu@jp.fujitsu.com>
	<20110309164801.3a4c8d10.kamezawa.hiroyu@jp.fujitsu.com>
	<20110309100020.GD30778@cmpxchg.org>
	<20110310083659.fd8b1c3f.kamezawa.hiroyu@jp.fujitsu.com>
	<20110310144752.289483d4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110310150428.f175758c.nishimura@mxp.nes.nec.co.jp>
	<20110310142029.5d108e37.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>

On Thu, 10 Mar 2011 14:20:29 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Thu, 10 Mar 2011 15:04:28 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > > Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
> > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > 
> > I hope this can fix the original BZ case.
> 
> Do you recall the buzilla bug number?
> 

Bug 30432

The patch works only when the user use FUSE.
We need to confirm that.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
