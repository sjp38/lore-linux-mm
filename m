Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C21D75F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 03:35:37 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n387a9x7000616
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 8 Apr 2009 16:36:09 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D11F45DD7D
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 16:36:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F12BA45DD7B
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 16:36:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D8AE71DB8040
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 16:36:08 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 82A911DB8042
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 16:36:08 +0900 (JST)
Date: Wed, 8 Apr 2009 16:34:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFI] Shared accounting for memory resource controller
Message-Id: <20090408163440.4442dc3c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <344eb09a0904080031y4406c001n584725b87024755@mail.gmail.com>
References: <20090407063722.GQ7082@balbir.in.ibm.com>
	<20090407163331.8e577170.kamezawa.hiroyu@jp.fujitsu.com>
	<20090407080355.GS7082@balbir.in.ibm.com>
	<20090407172419.a5f318b9.kamezawa.hiroyu@jp.fujitsu.com>
	<20090408052904.GY7082@balbir.in.ibm.com>
	<20090408151529.fd6626c2.kamezawa.hiroyu@jp.fujitsu.com>
	<20090408070401.GC7082@balbir.in.ibm.com>
	<20090408160733.4813cb8d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090408071115.GD7082@balbir.in.ibm.com>
	<20090408161824.26f47077.kamezawa.hiroyu@jp.fujitsu.com>
	<344eb09a0904080031y4406c001n584725b87024755@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Bharata B Rao <bharata.rao@gmail.com>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, Rik van Riel <riel@surriel.com>, Bharata B Rao <bharata.rao@in.ibm.com>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Apr 2009 13:01:15 +0530
Bharata B Rao <bharata.rao@gmail.com> wrote:

> On Wed, Apr 8, 2009 at 12:48 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> > On Wed, 8 Apr 2009 12:41:15 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > 3. Using the above, we can then try to (using an algorithm you
> > > proposed), try to do some work for figuring out the shared percentage.
> > >
> > This is the point. At last. Why "# of shared pages" is important ?
> >
> > I wonder it's better to add new stat file as memory.cacheinfo which helps
> > following kind of commands.
> >
> > A #cacheinfo /cgroups/memory/group01/
> > A  A  A  /usr/lib/libc.so.1 A  A  30pages
> > A  A  A  /var/log/messages A  A  A 1 pages
> > A  A  A  /tmp/xxxxxx A  A  A  A  A  A 20 pages
> 
> Can I suggest that we don't add new files for additional stats and try
> as far as possible to include them in <controller>.stat file. Please
> note that we have APIs in libcgroup library which can return
> statistics from controllers associated with a cgroup and these APIs
> assume that stats are part of <controller>.stat file.
> 
Hmm ? Is there generic assumption as all cgroup has "stat" file ?
And libcgroup cause bug if the new entry is added to stat file ?
(IOW, libcgroup can't ignore new entry added ?)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
