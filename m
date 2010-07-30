Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A69AC6B02A4
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 07:02:20 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6UB2Ih4029338
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 30 Jul 2010 20:02:18 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id EAEE345DE51
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 20:02:17 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id CB47645DE4F
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 20:02:17 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B19341DB803C
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 20:02:17 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 566561DB805F
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 20:02:14 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 1/2] oom: badness heuristic rewrite
In-Reply-To: <20100729183809.ca4ed8be.akpm@linux-foundation.org>
References: <20100730091125.4AC3.A69D9226@jp.fujitsu.com> <20100729183809.ca4ed8be.akpm@linux-foundation.org>
Message-Id: <20100730195338.4AF6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 30 Jul 2010 20:02:13 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@in.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Fri, 30 Jul 2010 09:12:26 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > On Sat, 17 Jul 2010 12:16:33 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> > > 
> > > > This a complete rewrite of the oom killer's badness() heuristic 
> > > 
> > > Any comments here, or are we ready to proceed?
> > > 
> > > Gimme those acked-bys, reviewed-bys and tested-bys, please!
> > 
> > If he continue to resend all of rewrite patch, I continue to refuse them.
> > I explained it multi times.
> 
> There are about 1000 emails on this topic.  Please briefly explain it again.

Major homework are

- make patch series instead unreviewable all in one patch.
- kill oom_score_adj
- write test way and test result

So, I'm pending reviewing until finish them. I'd like to point out 
rest minor topics while reviewing process.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
