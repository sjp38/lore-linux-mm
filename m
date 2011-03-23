Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C60EE8D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 03:49:02 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 445E23EE0C1
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 16:48:59 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2985345DE5A
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 16:48:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 10DED45DE55
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 16:48:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id F3B9CE18003
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 16:48:58 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BCA89E08001
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 16:48:58 +0900 (JST)
Date: Wed, 23 Mar 2011 16:42:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/5] Revert "oom: give the dying task a higher priority"
Message-Id: <20110323164229.6b647004.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110322200657.B064.A69D9226@jp.fujitsu.com>
References: <20110315153801.3526.A69D9226@jp.fujitsu.com>
	<20110322194721.B05E.A69D9226@jp.fujitsu.com>
	<20110322200657.B064.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>

On Tue, 22 Mar 2011 20:06:48 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> This reverts commit 93b43fa55088fe977503a156d1097cc2055449a2.
> 
> The commit dramatically improve oom killer logic when fork-bomb
> occur. But, I've found it has nasty corner case. Now cpu cgroup
> has strange default RT runtime. It's 0! That said, if a process
> under cpu cgroup promote RT scheduling class, the process never
> run at all.
> 
> Eventually, kernel may hang up when oom kill occur.
> 
> The author need to resubmit it as adding knob and disabled
> by default if he really need this feature.
> 
> Cc: Luis Claudio R. Goncalves <lclaudio@uudg.org>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
