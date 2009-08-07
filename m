Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E34646B004D
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 23:17:20 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n773HOfj028978
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 7 Aug 2009 12:17:24 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F5DC2AFD63
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 12:17:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 47DA645DE60
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 12:17:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 157B41DB803E
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 12:17:24 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B05611DB8040
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 12:17:23 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
In-Reply-To: <4A7AD5DF.7090801@redhat.com>
References: <20090806100824.GO23385@random.random> <4A7AD5DF.7090801@redhat.com>
Message-Id: <20090807121443.5BE5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Fri,  7 Aug 2009 12:17:22 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrea Arcangeli <aarcange@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Andrea Arcangeli wrote:
> 
> > Likely we need a cut-off point, if we detect it takes more than X
> > seconds to scan the whole active list, we start ignoring young bits,
> 
> We could just make this depend on the calculated inactive_ratio,
> which depends on the size of the list.
> 
> For small systems, it may make sense to make every accessed bit
> count, because the working set will often approach the size of
> memory.
> 
> On very large systems, the working set may also approach the
> size of memory, but the inactive list only contains a small
> percentage of the pages, so there is enough space for everything.
> 
> Say, if the inactive_ratio is 3 or less, make the accessed bit
> on the active lists count.

Sound reasonable. How do we confirm the idea correctness?
Wu, your X focus switching benchmark is sufficient test?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
