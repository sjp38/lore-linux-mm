Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 7422A6B0096
	for <linux-mm@kvack.org>; Sun, 11 Dec 2011 19:50:43 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 239593EE0BC
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:50:42 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0896345DE51
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:50:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E3CA245DE4D
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:50:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D4E621DB803B
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:50:41 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 884FC1DB802F
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:50:41 +0900 (JST)
Date: Mon, 12 Dec 2011 09:49:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3] mm: simplify find_vma_prev
Message-Id: <20111212094930.9d4716e1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1323470921-12931-1-git-send-email-kosaki.motohiro@gmail.com>
References: <1323466526.27746.29.camel@joe2Laptop>
	<1323470921-12931-1-git-send-email-kosaki.motohiro@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Andrew Morton (commit_signer:15/23=65%)" <akpm@linux-foundation.org>, "Hugh Dickins (commit_signer:7/23=30%)" <hughd@google.com>, "Peter Zijlstra (commit_signer:4/23=17%)" <a.p.zijlstra@chello.nl>, "Shaohua Li (commit_signer:3/23=13%)" <shaohua.li@intel.com>

On Fri,  9 Dec 2011 17:48:40 -0500
kosaki.motohiro@gmail.com wrote:

> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> commit 297c5eee37 (mm: make the vma list be doubly linked) added
> vm_prev member into vm_area_struct. Therefore we can simplify
> find_vma_prev() by using it. Also, this change help to improve
> page fault performance because it has strong locality of reference.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
