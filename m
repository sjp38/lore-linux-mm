Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 937016B01F0
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 20:19:15 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7P0MjIZ010024
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 25 Aug 2010 09:22:45 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id EE66745DE52
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 09:22:44 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C2BC045DE50
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 09:22:44 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8CB951DB801F
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 09:22:44 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 368681DB8017
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 09:22:44 +0900 (JST)
Date: Wed, 25 Aug 2010 09:17:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/5] cgroup: ID notification call back
Message-Id: <20100825091747.f6ea9e0e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTi=HwPeWafzTBh66g37XxZouKicsemmnTE-Cvz=Y@mail.gmail.com>
References: <20100820185552.426ff12e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100820185816.1dbcd53a.kamezawa.hiroyu@jp.fujitsu.com>
	<4C738B34.6070602@cn.fujitsu.com>
	<AANLkTi=HwPeWafzTBh66g37XxZouKicsemmnTE-Cvz=Y@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kamezawa.hiroyuki@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, 24 Aug 2010 17:11:22 -0700
Paul Menage <menage@google.com> wrote:

> On Tue, Aug 24, 2010 at 2:04 AM, Li Zefan <lizf@cn.fujitsu.com> wrote:
> >
> > Maybe pass the id number to id_attached() is better.
> >
> > And actually the @ss argument is not necessary, because the memcg's
> > id_attached() handler of course knows it's dealing with the memory
> > cgroup subsystem.
> >
> > So I suspect we can just remove all the @ss from all the callbacks..
> 
> Yes, I don't think any subsystem uses these. They dated originally
> from when, as part of the initial cgroups framwork, I included a
> library that could wrap a mostly-unmodified CKRM resource controller
> into a cgroups subsystem, at which point the callback code didn't
> necessarily know which subsystem it was being called for. But that's
> obsolete now.
> 

Hmm, then, should I remove it in the next version, or leave it as it is
now and should be removed by another total clean up ?

(IOW, mixture of inconsistent interface is O.K. ?)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
