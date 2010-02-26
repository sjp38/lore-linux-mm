Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 36FAB6B0047
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 00:54:09 -0500 (EST)
Date: Fri, 26 Feb 2010 14:47:52 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 1/2] memcg: oom kill handling improvement
Message-Id: <20100226144752.19734ff0.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100226142339.7a67f1a8.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100224165921.cb091a4f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100226131552.07475f9c.nishimura@mxp.nes.nec.co.jp>
	<20100226142339.7a67f1a8.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, rientjes@google.com, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

On Fri, 26 Feb 2010 14:23:39 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 26 Feb 2010 13:15:52 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > On Wed, 24 Feb 2010 16:59:21 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > These are dump of patches just for showing concept, what I want to do.
> > > But not tested. please see if you have free time. (you can ignore ;)
> > > 
> > > Anyway, this will HUNK to the latest mmotm, Kirill's work is merged.
> > > 
> > > This is not related to David's work. I don't hesitate to rebase mine
> > > to the mmotm if his one is merged, it's easy.
> > > But I'm not sure his one goes to mm soon. 
> > > 
> > > 1st patch is for better handling oom-kill under memcg.
> > It's bigger than I expected, but it basically looks good to me.
> > 
> 
> BTW, do you think we need quick fix ? I can't think of a very easy/small fix
> which is very correct...
To be honest, yes.
IMHO, casing global oom because of memcg's oom is a very bad behavior
in the sence of resource isolation. But I agree it's hard to fix in simple way,
so leave it as it is for now..
hmm.. I must admit that I've not done enough oom test under very high pressure.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
