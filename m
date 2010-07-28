Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 127BA6B02AA
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 10:17:13 -0400 (EDT)
Date: Wed, 28 Jul 2010 10:17:05 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [RFC][PATCH 4/7][memcg] memcg use ID in page_cgroup
Message-ID: <20100728141705.GA16314@redhat.com>
References: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
 <20100727165629.6f98145c.kamezawa.hiroyu@jp.fujitsu.com>
 <20100728023904.GE12642@redhat.com>
 <20100728114402.571b8ec6.kamezawa.hiroyu@jp.fujitsu.com>
 <20100728031358.GG12642@redhat.com>
 <20100728121820.0475142a.kamezawa.hiroyu@jp.fujitsu.com>
 <20100728122128.411f2128.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100728122128.411f2128.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 28, 2010 at 12:21:28PM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 28 Jul 2010 12:18:20 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>  
> > > > Hmm, but page-allocation-time doesn't sound very good for me.
> > > > 
> > > 
> > > Why?
> > > 
> > 
> > As you wrote, by attaching ID when a page cache is added, we'll have
> > much chances of free-rider until it's paged out. So, adding some
> > reseting-owner point may be good. 
> > 
> > But considering real world usage, I may be wrong.
> > There will not be much free rider in real world, especially at write().
> > Then, page-allocation time may be good.
> > 
> > (Because database doesn't use page-cache, there will be no big random write
> >  application.)
> > 
> 
> Sorry, one more reason. memory cgroup has much complex code for supporting
> move_account, re-attaching memory cgroup per pages.
> So, if you take care of task-move-between-groups, blkio-ID may have
> some problems if you only support allocation-time accounting.

I think initially we can just keep it simple for blkio controller and
not move page charges across blkio cgroup when process moves.

Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
