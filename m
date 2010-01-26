Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A3F096B008A
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 18:47:44 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0QNlfd9006976
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 27 Jan 2010 08:47:42 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8606C45DE53
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 08:47:41 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6375245DE4E
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 08:47:41 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 48C361DB8040
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 08:47:41 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id EC5AD1DB8038
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 08:47:40 +0900 (JST)
Date: Wed, 27 Jan 2010 08:44:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
Message-Id: <20100127084419.248bb3a7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100126151606.54764be2.akpm@linux-foundation.org>
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>
	<20100122152332.750f50d9.kamezawa.hiroyu@jp.fujitsu.com>
	<20100125151503.49060e74.kamezawa.hiroyu@jp.fujitsu.com>
	<20100126151606.54764be2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, rientjes@google.com, minchan.kim@gmail.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 26 Jan 2010 15:16:06 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 25 Jan 2010 15:15:03 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > -unsigned long badness(struct task_struct *p, unsigned long uptime)
> > +unsigned long badness(struct task_struct *p, unsigned long uptime,
> > +			int constraint)
> 
> And badness() should be renamed to something better (eg, oom_badness), and
> the declaration should be placed in a mm-specific header file.
> 
> Yes, the code was already like that.  But please don't leave crappiness in
> place when you come across it - take the opportunity to fix it up.
> 
Sure. I'll write v4.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
