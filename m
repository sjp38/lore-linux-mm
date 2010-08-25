Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 889B66B01F0
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 20:07:58 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id o7P0BOEp001462
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 17:11:25 -0700
Received: from pvg7 (pvg7.prod.google.com [10.241.210.135])
	by wpaz33.hot.corp.google.com with ESMTP id o7P0BMEp010136
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 17:11:23 -0700
Received: by pvg7 with SMTP id 7so8399pvg.31
        for <linux-mm@kvack.org>; Tue, 24 Aug 2010 17:11:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4C738B34.6070602@cn.fujitsu.com>
References: <20100820185552.426ff12e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100820185816.1dbcd53a.kamezawa.hiroyu@jp.fujitsu.com>
	<4C738B34.6070602@cn.fujitsu.com>
Date: Tue, 24 Aug 2010 17:11:22 -0700
Message-ID: <AANLkTi=HwPeWafzTBh66g37XxZouKicsemmnTE-Cvz=Y@mail.gmail.com>
Subject: Re: [PATCH 1/5] cgroup: ID notification call back
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kamezawa.hiroyuki@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, Aug 24, 2010 at 2:04 AM, Li Zefan <lizf@cn.fujitsu.com> wrote:
>
> Maybe pass the id number to id_attached() is better.
>
> And actually the @ss argument is not necessary, because the memcg's
> id_attached() handler of course knows it's dealing with the memory
> cgroup subsystem.
>
> So I suspect we can just remove all the @ss from all the callbacks..

Yes, I don't think any subsystem uses these. They dated originally
from when, as part of the initial cgroups framwork, I included a
library that could wrap a mostly-unmodified CKRM resource controller
into a cgroups subsystem, at which point the callback code didn't
necessarily know which subsystem it was being called for. But that's
obsolete now.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
