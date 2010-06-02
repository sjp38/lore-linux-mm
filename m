Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id F0D236B01B7
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 09:54:08 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o52Ds43O021507
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 2 Jun 2010 22:54:05 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A528345DE54
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 22:54:04 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6571E45DE4E
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 22:54:04 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 42BE61DB805B
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 22:54:04 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id EC77A1DB8040
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 22:54:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/5] oom: select_bad_process: check PF_KTHREAD instead of !mm to skip kthreads
In-Reply-To: <alpine.DEB.2.00.1006011424200.16725@chino.kir.corp.google.com>
References: <20100601212023.GA24917@redhat.com> <alpine.DEB.2.00.1006011424200.16725@chino.kir.corp.google.com>
Message-Id: <20100602223612.F52D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Wed,  2 Jun 2010 22:54:03 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

> On Tue, 1 Jun 2010, Oleg Nesterov wrote:
> 
> > But yes, I agree, the problem is minor. But nevertheless it is bug,
> > the longstanding bug with the simple fix. Why should we "hide" this fix
> > inside the long series of non-trivial patches which rewrite oom-killer?
> > And it is completely orthogonal to other changes.
> > 
> 
> Again, the question is whether or not the fix is rc material or not, 
> otherwise there's no difference in the route that it gets upstream: the 
> patch is duplicated in both series.  If you feel that this minor issue 
> (which has never been reported in at least the last three years and 
> doesn't have any side effects other than a couple of millisecond delay 
> until unuse_mm() when the oom killer will kill something else) should be 
> addressed in 2.6.35-rc2, then that's a conversation to be had with Andrew.

Well, we have bugfix-at-first development rule. Why do you refuse our
development process?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
