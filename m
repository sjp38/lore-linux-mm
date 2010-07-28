Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3490D6B024D
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 23:23:12 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6S3N9bt008817
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Jul 2010 12:23:10 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id DF8E445DE54
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 12:23:08 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id BF86845DE52
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 12:23:08 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 96192E08004
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 12:23:08 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A741E18001
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 12:23:08 +0900 (JST)
Date: Wed, 28 Jul 2010 12:18:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 4/7][memcg] memcg use ID in page_cgroup
Message-Id: <20100728121820.0475142a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100728031358.GG12642@redhat.com>
References: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100727165629.6f98145c.kamezawa.hiroyu@jp.fujitsu.com>
	<20100728023904.GE12642@redhat.com>
	<20100728114402.571b8ec6.kamezawa.hiroyu@jp.fujitsu.com>
	<20100728031358.GG12642@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Vivek Goyal <vgoyal@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Jul 2010 23:13:58 -0400
Vivek Goyal <vgoyal@redhat.com> wrote:
 
> > > So the idea is that when a page is allocated, also store the blk_group
> > > id and once that page is submitted for writeback, we should be able
> > > to associate it to right blkio group?
> > > 
> > blk_cgroup id can be attached whenever you wants. please overwrite 
> > page_cgroup->blk_cgroup when it's necessary.
> 
> > Did you read Ikeda's patch ? I myself doesn't have patches at this point. 
> > This is just for make a room for recording blkio-ID, which was requested
> > for a year.
> 
> I have not read his patches yet. IIRC, previously there were issues
> regarding which group should be charged for the page. The person who
> allocated it or the thread which did last write to it etc... I guess
> we can sort that out later.
> 
> > 
> > Hmm, but page-allocation-time doesn't sound very good for me.
> > 
> 
> Why?
> 

As you wrote, by attaching ID when a page cache is added, we'll have
much chances of free-rider until it's paged out. So, adding some
reseting-owner point may be good. 

But considering real world usage, I may be wrong.
There will not be much free rider in real world, especially at write().
Then, page-allocation time may be good.

(Because database doesn't use page-cache, there will be no big random write
 application.)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
