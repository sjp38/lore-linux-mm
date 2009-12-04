Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0088A6B003D
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 19:47:38 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB40la0g007353
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 4 Dec 2009 09:47:37 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id BC7F245DE4F
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 09:47:36 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9DE6345DE3A
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 09:47:36 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 873B21DB803F
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 09:47:36 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D3451DB8038
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 09:47:33 +0900 (JST)
Date: Fri, 4 Dec 2009 09:44:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] oom_kill: use rss value instead of vm size for badness
Message-Id: <20091204094437.4a9ab001.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0912031514150.8928@chino.kir.corp.google.com>
References: <20091201131509.5C19.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.0912011414510.27500@chino.kir.corp.google.com>
	<20091202091739.5C3D.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.0912031514150.8928@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, vedran.furac@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 3 Dec 2009 15:25:05 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> If Andrew pushes the patch to change the baseline to rss 
> (oom_kill-use-rss-instead-of-vm-size-for-badness.patch) to Linus, I'll 
> strongly nack it because you totally lack the ability to identify memory 
> leakers as defined by userspace which should be the prime target for the 
> oom killer.  You have not addressed that problem, you've merely talked 
> around it, and yet the patch unbelievably still sits in -mm.
>
It's still cook-time about oom-kill patches and I'll ask Andrew not to send
it when he asks in mm-merge plan. At least, per-mm swap counter and lowmem-rss
counter is necessary. I'll rewrite fork-bomb detector, too.

Repeatedly saying, calculating badness from vm_size _only_ is bad.
I'm not sure how google's magical applications works, but in general,
vm_size doesn't means private memory usage i.e. how well oom-killer can free
pages.
And current oom-killer kills wrong process. Please share your idea to making
oom-killer better rather than just saying "don't do that".

Do you have good algorithm for detecting memory-leaking process in user land ?
I think I added some in my old set but it's not enough.
I'll add more statistics to mm_struct to do better work.

BTW, I hate oom_adj very much. It's nature of "shift" is hard to understand.
I wonder why static oom priority or oom_threshold was not implemented...

Thanks,
-Kame 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
