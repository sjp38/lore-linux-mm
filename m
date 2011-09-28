Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 396DE9000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 02:16:58 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B986B3EE0B5
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 15:16:54 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A000045DEB5
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 15:16:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 880C045DEB2
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 15:16:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7709D1DB803F
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 15:16:54 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C5321DB803B
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 15:16:54 +0900 (JST)
Date: Wed, 28 Sep 2011 15:15:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V10 0/6] mm: frontswap: overview (and proposal to merge
 at next window)
Message-Id: <20110928151558.dca1da5e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110915213305.GA26317@ca-server1.us.oracle.com>
References: <20110915213305.GA26317@ca-server1.us.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, konrad.wilk@oracle.com, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, chris.mason@oracle.com, sjenning@linux.vnet.ibm.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

On Thu, 15 Sep 2011 14:33:05 -0700
Dan Magenheimer <dan.magenheimer@oracle.com> wrote:

> [PATCH V10 0/6] mm: frontswap: overview (and proposal to merge at next window)
> 
> (Note: V9->V10 only change is corrections in debugfs-related code/counters)
> 
> (Note to earlier reviewers:  This patchset was reorganized at V9 due
> to feedback from Kame Hiroyuki and Andrew Morton.  Additionally, feedback
> on frontswap v8 from Andrew Morton also applies to cleancache, to wit:
>  (1) change usage of sysfs to debugfs to avoid unnecessary kernel ABIs
>  (2) rename all uses of "flush" to "invalidate"
> As a result, additional patches (5of6 and 6of6) were added to this
> series at V9 to patch cleancache core code and cleancache hooks in the mm
> and fs subsystems and update cleancache documentation accordingly.)
> 

I'm sorry I couldn't catch following... what happens at hibernation ?
frontswap is effectively stopped/skipped automatically ? or contents of
TMEM can be kept after power off and it can be read correctly when
resume thread reads swap ?

In short: no influence to hibernation ?
I'm sorry if I misunderstand some.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
