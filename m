Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 546236B0044
	for <linux-mm@kvack.org>; Wed,  7 Jan 2009 19:38:06 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n080c3vX009690
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 8 Jan 2009 09:38:03 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 363AB45DE54
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 09:38:03 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0211445DE53
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 09:38:03 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A9E5D1DB8066
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 09:38:02 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 475B61DB8060
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 09:38:02 +0900 (JST)
Date: Thu, 8 Jan 2009 09:37:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/4] Memory controller soft limit patches
Message-Id: <20090108093700.2ad10d85.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090107185627.GL4145@linux.vnet.ibm.com>
References: <20090107184110.18062.41459.sendpatchset@localhost.localdomain>
	<20090107185627.GL4145@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

On Thu, 8 Jan 2009 00:26:27 +0530
Dhaval Giani <dhaval@linux.vnet.ibm.com> wrote:

> On Thu, Jan 08, 2009 at 12:11:10AM +0530, Balbir Singh wrote:
> > 
> > Here is v1 of the new soft limit implementation. Soft limits is a new feature
> > for the memory resource controller, something similar has existed in the
> > group scheduler in the form of shares. We'll compare shares and soft limits
> > below. I've had soft limit implementations earlier, but I've discarded those
> > approaches in favour of this one.
> > 
> > Soft limits are the most useful feature to have for environments where
> > the administrator wants to overcommit the system, such that only on memory
> > contention do the limits become active. The current soft limits implementation
> > provides a soft_limit_in_bytes interface for the memory controller and not
> > for memory+swap controller. The implementation maintains an RB-Tree of groups
> > that exceed their soft limit and starts reclaiming from the group that
> > exceeds this limit by the maximum amount.
> > 
> > This is an RFC implementation and is not meant for inclusion
> > 
> > TODOs
> > 
> > 1. The shares interface is not yet implemented, the current soft limit
> >    implementation is not yet hierarchy aware. The end goal is to add
> >    a shares interface on top of soft limits and to maintain shares in
> >    a manner similar to the group scheduler
> 
> Just to clarify, when there is no contention, you want to share memory
> proportionally?
> 
I don't like to add "share" as the kernel interface of memcg.
We used "bytes" to do (hard) limit. Please just use "bytes".

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
