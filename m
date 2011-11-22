Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 55FF26B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 19:37:38 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 96D493EE0BD
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 09:37:35 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7CCB645DE4F
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 09:37:35 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6067745DE4D
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 09:37:35 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5166AE18001
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 09:37:35 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 198251DB802F
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 09:37:35 +0900 (JST)
Date: Tue, 22 Nov 2011 09:36:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] fix mem_cgroup_split_huge_fixup to work efficiently.
Message-Id: <20111122093622.eba8bbef.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CAKTCnzk81UiqVHGcTcN_0iyG8dw=-wC6jo8ME7g303PQFKDM3w@mail.gmail.com>
References: <20111117103308.063f78df.kamezawa.hiroyu@jp.fujitsu.com>
	<CAKTCnzk81UiqVHGcTcN_0iyG8dw=-wC6jo8ME7g303PQFKDM3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, mhocko@suse.cz, Andrea Arcangeli <aarcange@redhat.com>

On Mon, 21 Nov 2011 16:30:11 +0530
Balbir Singh <bsingharora@gmail.com> wrote:

> On Thu, Nov 17, 2011 at 7:03 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> > I'll send this again when mm is shipped.
> > I sometimes see mem_cgroup_split_huge_fixup() in perf report and noticed
> > it's very slow. This fixes it. Any comments are welcome.
> >
> 
> How do you see this - what tests?
> 
Sometimes. By applications calling fork() or mremap(), mprotect(), which
will cause split_huge_page(). 
But not 100% reporoducable, yet.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
