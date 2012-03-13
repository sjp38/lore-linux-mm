Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 2B4E16B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 01:15:32 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 17D873EE0C0
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 14:15:30 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EF3CA45DEB5
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 14:15:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D4D7745DEB4
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 14:15:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B9C541DB803F
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 14:15:29 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 539551DB8044
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 14:15:29 +0900 (JST)
Date: Tue, 13 Mar 2012 14:13:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: revert fix to mapcount check for this release
Message-Id: <20120313141352.e390056f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1203091335020.19372@eggly.anvils>
References: <1330719189-20047-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1330719189-20047-2-git-send-email-n-horiguchi@ah.jp.nec.com>
	<20120309101658.8b36ce4f.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1203081816170.18242@eggly.anvils>
	<20120309122448.92931dc6.kamezawa.hiroyu@jp.fujitsu.com>
	<20120309150109.51ba8ea1.nishimura@mxp.nes.nec.co.jp>
	<20120309162357.71c8c573.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1203091225440.19372@eggly.anvils>
	<alpine.LSU.2.00.1203091335020.19372@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrea Arcangeli <aarcange@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 9 Mar 2012 13:37:32 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> Respectfully revert commit e6ca7b89dc76 "memcg: fix mapcount check
> in move charge code for anonymous page" for the 3.3 release, so that
> it behaves exactly like releases 2.6.35 through 3.2 in this respect.
> 
> Horiguchi-san's commit is correct in itself, 1 makes much more sense
> than 2 in that check; but it does not go far enough - swapcount
> should be considered too - if we really want such a check at all.
> 
> We appear to have reached agreement now, and expect that 3.4 will
> remove the mapcount check, but had better not make 3.3 different.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
