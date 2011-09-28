Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D3A6C9000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 04:14:03 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 3CAC63EE0C3
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 17:14:00 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 218EF45DEB5
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 17:14:00 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F1ADC45DEB3
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 17:13:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E10591DB8040
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 17:13:59 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A912D1DB803B
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 17:13:59 +0900 (JST)
Date: Wed, 28 Sep 2011 17:13:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 6/9] kstaled: rate limit pages scanned per second.
Message-Id: <20110928171309.b45c684f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1317170947-17074-7-git-send-email-walken@google.com>
References: <1317170947-17074-1-git-send-email-walken@google.com>
	<1317170947-17074-7-git-send-email-walken@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>

On Tue, 27 Sep 2011 17:49:04 -0700
Michel Lespinasse <walken@google.com> wrote:

> Scan some number of pages from each node every second, instead of trying to
> scan the entime memory at once and being idle for the rest of the configured
> interval.
> 
> In addition to spreading the CPU usage over the entire scanning interval,
> this also reduces the jitter between two consecutive scans of the same page.
> 
> 
> Signed-off-by: Michel Lespinasse <walken@google.com>

Does this scan thread need to be signle thread ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
