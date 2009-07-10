Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 44E0B6B005C
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 03:53:43 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6A8Ghfr002976
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 10 Jul 2009 17:16:43 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 918A245DE58
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 17:16:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E4B345DE56
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 17:16:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 295ED1DB8041
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 17:16:43 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C0C0DE18010
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 17:16:41 +0900 (JST)
Date: Fri, 10 Jul 2009 17:14:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 3/5] Memory controller soft limit organize cgroups
 (v8)
Message-Id: <20090710171457.e2e52319.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090710080557.GF20129@balbir.in.ibm.com>
References: <20090709171441.8080.85983.sendpatchset@balbir-laptop>
	<20090709171501.8080.85138.sendpatchset@balbir-laptop>
	<20090710142135.8079cd22.kamezawa.hiroyu@jp.fujitsu.com>
	<20090710080557.GF20129@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 10 Jul 2009 13:35:57 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-07-10 14:21:35]:
> 
> > 
> > As pointed out in several times, plz avoid using jiffies.
> 
> Sorry, I forgot to respond to this part. Are you suggesting we avoid
> jiffies (use ktime_t) or the time based approach. I responded to the
> time base versus scanning approach to the mail earlier.
> 
> -

IIUC, it was a comment to old patches "don't use jiffies, count event"
(by Andrew Morton ?) I fully agree with that.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
