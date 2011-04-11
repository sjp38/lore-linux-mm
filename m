Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1708D8D003B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 00:11:15 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 87F023EE081
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 13:11:10 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6EF8645DE55
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 13:11:10 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 584E545DE4E
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 13:11:10 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D4B91DB803C
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 13:11:10 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 130671DB8038
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 13:11:10 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: mmotm 2011-03-31-14-48 uploaded
In-Reply-To: <20110403181147.AE42.A69D9226@jp.fujitsu.com>
References: <201103312224.p2VMOA5g000983@imap1.linux-foundation.org> <20110403181147.AE42.A69D9226@jp.fujitsu.com>
Message-Id: <20110411131152.0069.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 11 Apr 2011 13:11:09 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@elte.hu>

> > The mm-of-the-moment snapshot 2011-03-31-14-48 has been uploaded to
> > 
> >    http://userweb.kernel.org/~akpm/mmotm/
> > 
> > and will soon be available at
> > 
> >    git://zen-kernel.org/kernel/mmotm.git
> > 
> 
> This doesn't boot.
> 
> =======================================================================
> [    0.169037] divide error: 0000 [#1] SMP
> [    0.169982] last sysfs file:
> [    0.169982] CPU 0
> [    0.169982] Modules linked in:
> [    0.169982]
> [    0.169982] Pid: 1, comm: swapper Not tainted 2.6.39-rc1-mm1+ #2 FUJITSU-SV      PRIMERGY                      /D2559-A1
> [    0.169982] RIP: 0010:[<ffffffff8104ad4c>]  [<ffffffff8104ad4c>] find_busiest_group+0x38c/0xd30

Please don't worry. This is not -mm problem. The breakage is in linus-tree.
Now fake numa feature doesn't work correctly and I and Tejun are discussing 
about a fix.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
