Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 718E86B02A4
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 20:12:31 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6U0CShW012214
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 30 Jul 2010 09:12:28 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5AA7445DE55
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 09:12:28 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BEC145DE51
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 09:12:28 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 161251DB803C
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 09:12:28 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CC26F1DB803A
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 09:12:27 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 1/2] oom: badness heuristic rewrite
In-Reply-To: <20100729160822.cd910c1b.akpm@linux-foundation.org>
References: <alpine.DEB.2.00.1007170307110.8730@chino.kir.corp.google.com> <20100729160822.cd910c1b.akpm@linux-foundation.org>
Message-Id: <20100730091125.4AC3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 30 Jul 2010 09:12:26 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@in.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Sat, 17 Jul 2010 12:16:33 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> 
> > This a complete rewrite of the oom killer's badness() heuristic 
> 
> Any comments here, or are we ready to proceed?
> 
> Gimme those acked-bys, reviewed-bys and tested-bys, please!

If he continue to resend all of rewrite patch, I continue to refuse them.
I explained it multi times.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
