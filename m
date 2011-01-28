Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2151B8D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 00:57:02 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id CB5FB3EE0B6
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 14:56:58 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B39B945DE55
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 14:56:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F48145DE4E
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 14:56:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 896041DB803E
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 14:56:58 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 533861DB803A
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 14:56:58 +0900 (JST)
Date: Fri, 28 Jan 2011 14:50:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH 3/4] mecg: fix oom flag at THP charge
Message-Id: <20110128145035.d20af975.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110128143912.66f60a22.nishimura@mxp.nes.nec.co.jp>
References: <20110128122229.6a4c74a2.kamezawa.hiroyu@jp.fujitsu.com>
	<20110128122729.1f1c613e.kamezawa.hiroyu@jp.fujitsu.com>
	<20110128143912.66f60a22.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 28 Jan 2011 14:39:12 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Fri, 28 Jan 2011 12:27:29 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > 
> > Thanks to Johanns and Daisuke for suggestion.
> > =
> > Hugepage allocation shouldn't trigger oom.
> > Allocation failure is not fatal.
> > 
> > Orignal-patch-by: Johannes Weiner <hannes@cmpxchg.org>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> IIUC, this patch isn't necessary because we don't go into oom
> in "page_size > PAGE_SIZE" case after [2/4].
> But I think it's not so bad to show explicitly that we don't cause oom in
> THP charge.
> 
> Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 

Thank you for clarification.

-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
