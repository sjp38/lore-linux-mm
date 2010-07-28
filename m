Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 56ACB6B02A3
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 23:26:20 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6S3QHrg030941
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Jul 2010 12:26:17 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id CA76745DE55
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 12:26:16 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9EEE645DE4E
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 12:26:16 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 493F21DB8016
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 12:26:16 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B0B1E38002
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 12:26:15 +0900 (JST)
Date: Wed, 28 Jul 2010 12:21:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 4/7][memcg] memcg use ID in page_cgroup
Message-Id: <20100728122128.411f2128.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100728121820.0475142a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100727165629.6f98145c.kamezawa.hiroyu@jp.fujitsu.com>
	<20100728023904.GE12642@redhat.com>
	<20100728114402.571b8ec6.kamezawa.hiroyu@jp.fujitsu.com>
	<20100728031358.GG12642@redhat.com>
	<20100728121820.0475142a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 28 Jul 2010 12:18:20 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
 
> > > Hmm, but page-allocation-time doesn't sound very good for me.
> > > 
> > 
> > Why?
> > 
> 
> As you wrote, by attaching ID when a page cache is added, we'll have
> much chances of free-rider until it's paged out. So, adding some
> reseting-owner point may be good. 
> 
> But considering real world usage, I may be wrong.
> There will not be much free rider in real world, especially at write().
> Then, page-allocation time may be good.
> 
> (Because database doesn't use page-cache, there will be no big random write
>  application.)
> 

Sorry, one more reason. memory cgroup has much complex code for supporting
move_account, re-attaching memory cgroup per pages.
So, if you take care of task-move-between-groups, blkio-ID may have
some problems if you only support allocation-time accounting.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
