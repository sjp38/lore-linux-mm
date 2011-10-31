Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9AD6A6B006C
	for <linux-mm@kvack.org>; Mon, 31 Oct 2011 04:14:42 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 946583EE0C0
	for <linux-mm@kvack.org>; Mon, 31 Oct 2011 17:14:39 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D6A045DE96
	for <linux-mm@kvack.org>; Mon, 31 Oct 2011 17:14:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3876545DE92
	for <linux-mm@kvack.org>; Mon, 31 Oct 2011 17:14:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 289531DB804D
	for <linux-mm@kvack.org>; Mon, 31 Oct 2011 17:14:39 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E89F21DB8045
	for <linux-mm@kvack.org>; Mon, 31 Oct 2011 17:14:38 +0900 (JST)
Date: Mon, 31 Oct 2011 17:13:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
Message-Id: <20111031171321.097a166c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, levinsasha928@gmail.com, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Neo Jia <cyclonusj@gmail.com>

On Thu, 27 Oct 2011 11:52:22 -0700 (PDT)
Dan Magenheimer <dan.magenheimer@oracle.com> wrote:

> Hi Linus --
> 
> Frontswap now has FOUR users: Two already merged in-tree (zcache
> and Xen) and two still in development but in public git trees
> (RAMster and KVM).  Frontswap is part 2 of 2 of the core kernel
> changes required to support transcendent memory; part 1 was cleancache
> which you merged at 3.0 (and which now has FIVE users).
> 
> Frontswap patches have been in linux-next since June 3 (with zero
> changes since Sep 22).  First posted to lkml in June 2009, frontswap 
> is now at version 11 and has incorporated feedback from a wide range
> of kernel developers.  For a good overview, see
>    http://lwn.net/Articles/454795.
> If further rationale is needed, please see the end of this email
> for more info.
> 
> SO... Please pull:
> 
> git://oss.oracle.com/git/djm/tmem.git #tmem
> 
> since git commit b6fd41e29dea9c6753b1843a77e50433e6123bcb
> Linus Torvalds (1):
> 

Why bypass -mm tree ?

I think you planned to merge this via -mm tree and, then, posted patches
to linux-mm with CC -mm guys.

I think you posted 2011/09/16 at the last time, v10. But no further submission
to gather acks/reviews from Mel, Johannes, Andrew, Hugh etc.. and no inclusion
request to -mm or -next. _AND_, IIUC, at v10, the number of posted pathces was 6.
Why now 8 ? Just because it's simple changes ? 

I don't have heavy concerns to the codes itself but this process as bypassing -mm
or linux-next seems ugly.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
