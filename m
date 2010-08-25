Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BDB8F6B01F0
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 20:39:08 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7P0gj5f015065
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 25 Aug 2010 09:42:45 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D689C45DE4F
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 09:42:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A962545DE4D
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 09:42:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 96EB51DB8050
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 09:42:44 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5211D1DB803C
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 09:42:44 +0900 (JST)
Date: Wed, 25 Aug 2010 09:37:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/5] cgroup: ID notification call back
Message-Id: <20100825093747.24085b28.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTikD3CFRPo7WvWwCnLQ+jzEs6rUk1sivYM3aRbGJ@mail.gmail.com>
References: <20100820185552.426ff12e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100820185816.1dbcd53a.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=imK6Px+JrdVupg2V3jtN9pgmEdWv=+aB1XKLY@mail.gmail.com>
	<20100825092010.cfe91b1a.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikD3CFRPo7WvWwCnLQ+jzEs6rUk1sivYM3aRbGJ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kamezawa.hiroyuki@gmail.com, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Aug 2010 17:34:38 -0700
Paul Menage <menage@google.com> wrote:

> On Tue, Aug 24, 2010 at 5:20 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> > Hmm, sure. I'll change the ->create() interface. A O.K. ?
> >
> 
> Hmm. An alternative (possibly cleaner) would be:
> 
> 1) add a css_size field in cgroup_subsys that contains the size of the
> per-subsystem structure
> 2) change cgroups to allocate and populate the css *before* calling
> create(), since it now knows the actual size
> 3) simplify all the subsystem create() methods since they no longer
> have to worry about allocation or out-of-memory handling
> 4) also add a top_css field in cgroups that allows cpusets to use the
> statically-allocated top_cpuset since it's initialized prior to memory
> allocation being reliable
> 
> This avoids us having to pass in any new parameters to the create()
> method in future since they can be populated in the CSS.
> 

Ou...I'm sorry but I would like to use attach_id() for this time.
Forgive me, above seems a big change.
I'd like to write a series of patch to do above, later.
At least, to do a trial.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
