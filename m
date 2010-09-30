Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 39CFB6B0047
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 01:37:03 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8U5b0Gf002824
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 30 Sep 2010 14:37:00 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B6C545DE56
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 14:37:00 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id EBE1845DE53
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 14:36:59 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id CCB8F1DB805A
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 14:36:59 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A74E51DB8038
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 14:36:58 +0900 (JST)
Date: Thu, 30 Sep 2010 14:31:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/4] memcg: use ID instead of pointer in
 page_cgroup , retry v2.
Message-Id: <20100930143147.82143840.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100927184821.f4bf2b2c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100924181302.7d764e0d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100927184821.f4bf2b2c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Sep 2010 18:48:21 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Fri, 24 Sep 2010 18:13:02 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > 
> > This is a reviced series of use ID.
> > Restart from RFC.
> > 
> 
> Then, I changed my mind..This is a new set. No new special lookups.
> But you may feel somethig strange. I don't want to merge these patches
> at once. Just think this set as a dump of my stack. Any comments are welcome.
> 

At LinuxCon Japan, I talked with Nishimura and just sending only patch 1/4
will be best (go step-by-step). And I know Greg Thelen now rewrite his
dirty page accounting for memcg patch onto the latest mmotm. I think current
priority of it is higher than this. So, I'll wait for a while and post only
patch 1/4.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
