Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBA18E4g007473
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 10 Dec 2008 10:08:14 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 48A0345DD7F
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 10:08:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2381F45DD82
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 10:08:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D88901DB8040
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 10:08:13 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 91E5D1DB803E
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 10:08:13 +0900 (JST)
Date: Wed, 10 Dec 2008 10:07:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/6] memcg: Documentation for internal
 implementation
Message-Id: <20081210100717.0428a49e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <493F151B.50800@cn.fujitsu.com>
References: <20081209200213.0e2128c1.kamezawa.hiroyu@jp.fujitsu.com>
	<20081209200413.d842ede4.kamezawa.hiroyu@jp.fujitsu.com>
	<20081210092735.25d9d618.kamezawa.hiroyu@jp.fujitsu.com>
	<493F151B.50800@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 10 Dec 2008 09:02:19 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > Paul, Balbir
> > 
> > I have a question.
> > 
> > Why cgroup's documentation directroy is divided into 2 places ?
> > 
> > 	Documentation/cgroups
> > 	             /controllers
> > 
> 
> Documentation/cgroups was created by Matt Helsley, when he added freezer-subsystem.txt,
> and he also moved cgroups.txt to the new Documentation/cgroups.
> 
> > If no strong demands, I'd like to remove "controllers" directroy and move
> 
> I prepared a patch to do so long ago, but didn't ever send it out.
> 
Thank you for clarification. Then, it seems there are no special meanings.
I think people tends to recognize codes as "cgroups" rather than "controllers".
I'd like to prepare a patch after sending this update out.
If you do, I'll adjust my updates.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
