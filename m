Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3EE246B0047
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 00:27:15 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1Q5RBLV005617
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 26 Feb 2010 14:27:11 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 71E2E45DE60
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 14:27:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F1C445DE6E
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 14:27:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D7C14E18001
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 14:27:10 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5AACB1DB8042
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 14:27:10 +0900 (JST)
Date: Fri, 26 Feb 2010 14:23:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/2] memcg: oom kill handling improvement
Message-Id: <20100226142339.7a67f1a8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100226131552.07475f9c.nishimura@mxp.nes.nec.co.jp>
References: <20100224165921.cb091a4f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100226131552.07475f9c.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Fri, 26 Feb 2010 13:15:52 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Wed, 24 Feb 2010 16:59:21 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > These are dump of patches just for showing concept, what I want to do.
> > But not tested. please see if you have free time. (you can ignore ;)
> > 
> > Anyway, this will HUNK to the latest mmotm, Kirill's work is merged.
> > 
> > This is not related to David's work. I don't hesitate to rebase mine
> > to the mmotm if his one is merged, it's easy.
> > But I'm not sure his one goes to mm soon. 
> > 
> > 1st patch is for better handling oom-kill under memcg.
> It's bigger than I expected, but it basically looks good to me.
> 

BTW, do you think we need quick fix ? I can't think of a very easy/small fix
which is very correct...

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
