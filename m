Date: Tue, 21 Oct 2008 19:15:39 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [memcg BUG] unable to handle kernel NULL pointer derefence at
 00000000
Message-Id: <20081021191539.2359c27b.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081021184138.905a1521.kamezawa.hiroyu@jp.fujitsu.com>
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
	<20081021184138.905a1521.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, Li Zefan <lizf@cn.fujitsu.com>, balbir@linux.vnet.ibm.com, Paul Menage <menage@google.com>, linux-mm@kvack.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Tue, 21 Oct 2008 18:41:38 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 21 Oct 2008 18:33:18 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > On Tue, 21 Oct 2008 17:57:35 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > On Tue, 21 Oct 2008 16:35:09 +0800
> > > Li Zefan <lizf@cn.fujitsu.com> wrote:
> > > 
> > > > KAMEZAWA Hiroyuki wrote:
> > > > > On Tue, 21 Oct 2008 15:21:07 +0800
> > > > > Li Zefan <lizf@cn.fujitsu.com> wrote:
> > > > >> dmesg is attached.
> > > > >>
> > > > > Thanks....I think I caught some. (added Mel Gorman to CC:)
> > > > > 
> > > > > NODE_DATA(nid)->spanned_pages just means sum of zone->spanned_pages in node.
> > > > > 
> > > > > So, If there is a hole between zone, node->spanned_pages doesn't mean
> > > > > length of node's memmap....(then, some hole can be skipped.)
> > > > > 
> > > > > OMG....Could you try this ? 
> > > > > 
> > > > 
> > > > No luck, the same bug still exists. :(
> > > > 
> > > This is a little fixed one..
> > > 
> > I can reproduce a similar problem(hang on boot) on 2.6.27-git9,
> > but this patch doesn't help either on my environment...
> > 
> > I attach a console log(I've not seen NULL pointer dereference yet).
> > 
> > 
> Thanks....boots well if cgroup_disable=memory ?
> 
Hum.. "cgroup_disable=memory" doesn't work either in my environment...

Maybe, I'm hitting a different problem.


Daisuke Nishimura.

> Thanks,
> -Kame
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
