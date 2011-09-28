Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 70E2A9000C6
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 02:53:58 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D38CB3EE0C1
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 15:53:53 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BC71345DE7F
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 15:53:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 927BD45DE81
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 15:53:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DF051DB803F
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 15:53:53 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FE151DB803A
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 15:53:53 +0900 (JST)
Date: Wed, 28 Sep 2011 15:53:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/9] kstaled: documentation and config option.
Message-Id: <20110928155302.ca394980.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1317170947-17074-3-git-send-email-walken@google.com>
References: <1317170947-17074-1-git-send-email-walken@google.com>
	<1317170947-17074-3-git-send-email-walken@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>

On Tue, 27 Sep 2011 17:49:00 -0700
Michel Lespinasse <walken@google.com> wrote:

> Extend memory cgroup documentation do describe the optional idle page
> tracking features, and add the corresponding configuration option.
> 
> 
> Signed-off-by: Michel Lespinasse <walken@google.com>

> +* idle_2_clean, idle_2_dirty_file, idle_2_dirty_swap: same definitions as
> +  above, but for pages that have been untouched for at least two scan cycles.
> +* these fields repeat up to idle_240_clean, idle_240_dirty_file and
> +  idle_240_dirty_swap, allowing one to observe idle pages over a variety
> +  of idle interval lengths. Note that the accounting is cumulative:
> +  pages counted as idle for a given interval length are also counted
> +  as idle for smaller interval lengths.

I'm sorry if you've answered already.

Why 240 ? and above means we have idle_xxx_clean/dirty/ xxx is 'seq 2 240' ?
Isn't it messy ? Anyway, idle_1_clean etc should be provided.

Hmm, I don't like the idea very much...

IIUC, there is no kernel interface which shows histgram rather than load_avg[].
Is there any other interface and what histgram is provided ?
And why histgram by kernel is required ? 

BTW, can't this information be exported by /proc/<pid>/smaps or somewhere ?
I guess per-proc will be wanted finally. 


Hm, do you use params other than idle_clean for your scheduling ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
