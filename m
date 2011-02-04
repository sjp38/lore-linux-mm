Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 654478D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 23:35:32 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C9C043EE0C5
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 13:35:29 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id ADC8145DE56
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 13:35:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 05B8045DE61
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 13:35:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DB3A0E78007
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 13:35:28 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A53D8E08006
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 13:35:28 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 22/25] mm: Convert anon_vma->lock to a mutex
In-Reply-To: <1296745495.26581.370.camel@laptop>
References: <20110203142716.93C5.A69D9226@jp.fujitsu.com> <1296745495.26581.370.camel@laptop>
Message-Id: <20110204133458.17CE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Fri,  4 Feb 2011 13:35:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Hugh Dickins <hughd@google.com>

> On Thu, 2011-02-03 at 14:27 +0900, KOSAKI Motohiro wrote:
> > > Straight fwd conversion of anon_vma->lock to a mutex.
> > > 
> > > Acked-by: Hugh Dickins <hughd@google.com>
> > > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > 
> > Don't I ack this series at previous iteration? If not, Hmmm.. I haven't remenber
> > the reason.
> 
> I got a +1 email from you on the spinlock to mutex conversion patch, I
> wasn't quite sure to what tag that translated.

I'm sorry. Maybe Im busy and I wrote unkindly mail. yes, it's my fault.


> >  Anyway
> > 	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> Is this for this particular patch, or for the series? 

series. please.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
