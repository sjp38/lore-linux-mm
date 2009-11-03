Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 572F26B0062
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 18:58:46 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA3NwhCU028838
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 4 Nov 2009 08:58:43 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E863D45DE53
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 08:58:42 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B7AA845DE4D
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 08:58:42 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 547D31DB8038
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 08:58:41 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 78CAC1DB8040
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 08:58:40 +0900 (JST)
Date: Wed, 4 Nov 2009 08:56:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][-mm][PATCH 0/6] oom-killer: total renewal
Message-Id: <20091104085604.f6e8b162.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0911031229590.25890@chino.kir.corp.google.com>
References: <20091102162244.9425e49b.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911031229590.25890@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, minchan.kim@gmail.com, vedran.furac@gmail.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Nov 2009 12:34:13 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Mon, 2 Nov 2009, KAMEZAWA Hiroyuki wrote:
> 
> > Hi, as discussed in "Memory overcommit" threads, I started rewrite.
> > 
> > This is just for showing "I started" (not just chating or sleeping ;)
> > 
> > All implemtations are not fixed yet. So feel free to do any comments.
> > This set is for minimum change set, I think. Some more rich functions
> > can be implemented based on this.
> > 
> > All patches are against "mm-of-the-moment snapshot 2009-11-01-10-01"
> > 
> > Patches are organized as
> > 
> > (1) pass oom-killer more information, classification and fix mempolicy case.
> > (2) counting swap usage
> > (3) counting lowmem usage
> > (4) fork bomb detector/killer
> > (5) check expansion of total_vm
> > (6) rewrite __badness().
> > 
> > passed small tests on x86-64 boxes.
> > 
> 
> Thanks for looking into improving the oom killer!
> 
Thank you for review.

> I think it would be easier to merge the four different concepts you have 
> here:
> 
>  - counting for swap usage (patch 2),
> 
>  - oom killer constraint reorganization (patches 1 and 3),
> 
>  - fork bomb detector (patch 4), and 
> 
>  - heuristic changes (patches 5 and 6)
> 
> into seperate patchsets and get them merged one at a time.

yes, I will do so. I think we share total view of final image.

> I think patch 2 can easily be merged into -mm now, and patches 1 and 3 could
> be merged after cleaned up. 
ok, maybe patch 1 should be separated more.

>We'll probably need more discussion on the rest.
> 
agreed.

> Patches 1 and 6 have whitespace damage, btw.
Oh, will fix.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
