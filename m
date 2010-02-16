Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8F58E6B007D
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 01:01:37 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1G61Zl8019365
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 16 Feb 2010 15:01:35 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A08C645DE4E
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 15:01:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7AE3445DE5D
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 15:01:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 54D46E78001
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 15:01:34 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 016FF1DB8038
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 15:01:34 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 1/7 -mm] oom: filter tasks not sharing the same cpuset
In-Reply-To: <20100216110859.72C6.A69D9226@jp.fujitsu.com>
References: <alpine.DEB.2.00.1002151401280.26927@chino.kir.corp.google.com> <20100216110859.72C6.A69D9226@jp.fujitsu.com>
Message-Id: <20100216150100.72F7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 16 Feb 2010 15:01:33 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


typo.

> But this explanation is irrelevant and meaningless. CPUSET can change

s/CPUSET/mempolicy/

> restricted node dynamically. So, the tsk->mempolicy at oom time doesn't
> represent the place of task's usage memory. plus, OOM_DISABLE can 
> always makes undesirable result. it's not special in this case.
> 
> The fact is, both current and your heuristics have a corner case. it's
> obvious. (I haven't seen corner caseless heuristics). then talking your
> patch's merit doesn't help to merge the patch. The most important thing
> is, we keep no regression. personally, I incline your one. but It doesn't
> mean we can ignore its demerit.
> 
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
