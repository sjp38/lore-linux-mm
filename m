Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3CA866B01F1
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 21:48:31 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o7P1qLak005481
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 18:52:22 -0700
Received: from pxi5 (pxi5.prod.google.com [10.243.27.5])
	by wpaz9.hot.corp.google.com with ESMTP id o7P1qKiC024234
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 18:52:20 -0700
Received: by pxi5 with SMTP id 5so18518pxi.40
        for <linux-mm@kvack.org>; Tue, 24 Aug 2010 18:52:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100825104240.7dbaba6a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100820185552.426ff12e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100820185816.1dbcd53a.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=imK6Px+JrdVupg2V3jtN9pgmEdWv=+aB1XKLY@mail.gmail.com>
	<20100825092010.cfe91b1a.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikD3CFRPo7WvWwCnLQ+jzEs6rUk1sivYM3aRbGJ@mail.gmail.com>
	<20100825093747.24085b28.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=KW_gxbmB14j5opSKL+-JFDFKO1YP6a7yvT8U5@mail.gmail.com>
	<20100825100310.ba3fd27e.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikuJ9x1u+GC_ox448Fp9wdJ2_GJyu6kNwjOJ9Y=@mail.gmail.com>
	<20100825104240.7dbaba6a.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 24 Aug 2010 18:52:20 -0700
Message-ID: <AANLkTinFdzzHxQhyGO9cPk+7kLw9WnRDnM+AekWFOn1q@mail.gmail.com>
Subject: Re: [PATCH 1/5] cgroup: ID notification call back
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kamezawa.hiroyuki@gmail.com, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 24, 2010 at 6:42 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> Hmm, but placing css and subsystem's its own structure in different cache line
> can increase cacheline/TLB miss, I think.

My patch shouldn't affect the memory placement of any structures.
struct cgroup_subsys_state is still embedded in the per-subsystem
state.

>
> Do we have to call alloc_css_id() in kernel/cgroup.c ?

I guess not, if no-one's using it except for memcg. The general
approach of allocating the CSS in cgroup.c rather than in every
subsystem is something that I'd like to do separately, though.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
