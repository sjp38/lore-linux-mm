Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9L9g4XE007463
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 21 Oct 2008 18:42:05 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B6391B801F
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 18:42:04 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (s7.gw.fujitsu.co.jp [10.0.50.97])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C63C2DC021
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 18:42:04 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id 438491DB8044
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 18:42:04 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id DCD151DB803E
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 18:42:03 +0900 (JST)
Date: Tue, 21 Oct 2008 18:41:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [memcg BUG] unable to handle kernel NULL pointer derefence at
 00000000
Message-Id: <20081021184138.905a1521.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081021183318.aa6364ec.nishimura@mxp.nes.nec.co.jp>
References: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp>
	<20081017195601.0b9abda1.nishimura@mxp.nes.nec.co.jp>
	<6599ad830810201253u3bca41d4rabe48eb1ec1d529f@mail.gmail.com>
	<20081021101430.d2629a81.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD6901.6050301@linux.vnet.ibm.com>
	<20081021143955.eeb86d49.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD74AB.9010307@cn.fujitsu.com>
	<20081021155454.db6888e4.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD7EEF.3070803@cn.fujitsu.com>
	<20081021161621.bb51af90.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD82E3.9050502@cn.fujitsu.com>
	<20081021171801.4c16c295.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD943D.5090709@cn.fujitsu.com>
	<20081021175735.0c3d3534.kamezawa.hiroyu@jp.fujitsu.com>
	<20081021183318.aa6364ec.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Li Zefan <lizf@cn.fujitsu.com>, balbir@linux.vnet.ibm.com, Paul Menage <menage@google.com>, linux-mm@kvack.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Tue, 21 Oct 2008 18:33:18 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Tue, 21 Oct 2008 17:57:35 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Tue, 21 Oct 2008 16:35:09 +0800
> > Li Zefan <lizf@cn.fujitsu.com> wrote:
> > 
> > > KAMEZAWA Hiroyuki wrote:
> > > > On Tue, 21 Oct 2008 15:21:07 +0800
> > > > Li Zefan <lizf@cn.fujitsu.com> wrote:
> > > >> dmesg is attached.
> > > >>
> > > > Thanks....I think I caught some. (added Mel Gorman to CC:)
> > > > 
> > > > NODE_DATA(nid)->spanned_pages just means sum of zone->spanned_pages in node.
> > > > 
> > > > So, If there is a hole between zone, node->spanned_pages doesn't mean
> > > > length of node's memmap....(then, some hole can be skipped.)
> > > > 
> > > > OMG....Could you try this ? 
> > > > 
> > > 
> > > No luck, the same bug still exists. :(
> > > 
> > This is a little fixed one..
> > 
> I can reproduce a similar problem(hang on boot) on 2.6.27-git9,
> but this patch doesn't help either on my environment...
> 
> I attach a console log(I've not seen NULL pointer dereference yet).
> 
> 
Thanks....boots well if cgroup_disable=memory ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
