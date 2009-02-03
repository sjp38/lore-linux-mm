Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 72F545F0001
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 20:23:11 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n131N8b0030544
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 3 Feb 2009 10:23:08 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 66F1845DD72
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 10:23:08 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A7AB45DD78
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 10:23:08 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 245C91DB8043
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 10:23:08 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C5231DB8040
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 10:23:07 +0900 (JST)
Date: Tue, 3 Feb 2009 10:21:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [-mm patch] Show memcg information during OOM
Message-Id: <20090203102157.9f643965.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090202140849.GB918@balbir.in.ibm.com>
References: <20090202125240.GA918@balbir.in.ibm.com>
	<20090202140849.GB918@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Feb 2009 19:38:49 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * Balbir Singh <balbir@linux.vnet.ibm.com> [2009-02-02 18:22:40]:
> 
> > Hi, All,
> > 
> > I found the following patch useful while debugging the memory
> > controller. It adds additional information if memcg invoked the OOM.
> > 
> > Comments, Suggestions?
> >
> 
> 
> Description: Add RSS and swap to OOM output from memcg
> 
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 

> This patch displays memcg values like failcnt, usage and limit
> when an OOM occurs due to memcg.
> 

please use "KB" not bytes in OOM killer information.

And the most important information is dropped..
Even if you show information, the most important information that
"where I am and where we hit limit ?" is not coverred.
Could you consider some way to show full-path ?

  OOM-Killer:
  Task in /memory/xxx/yyy/zzz is killed by
  Limit of /memory/xxxx
  RSS Limit :     Usage:     Failcnt....
  RSS+SWAP Limit: ....



Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
