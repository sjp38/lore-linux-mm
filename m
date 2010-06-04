Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3853B6B01B9
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 06:54:50 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o54AslQB025940
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 4 Jun 2010 19:54:47 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 922D045DE4F
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 19:54:47 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DCD445DD70
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 19:54:47 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F508E08002
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 19:54:47 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B773E08001
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 19:54:44 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 08/18] oom: badness heuristic rewrite
In-Reply-To: <20100603161532.8e41b42a.akpm@linux-foundation.org>
References: <20100603104314.723D.A69D9226@jp.fujitsu.com> <20100603161532.8e41b42a.akpm@linux-foundation.org>
Message-Id: <20100604172614.72BB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Fri,  4 Jun 2010 19:54:43 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi


> > In other word, I'm sure I'll continue to get OOM bug report in future.
> 
> You must have some reason for believing that.  Please share it with us.

In past, OOM bug report havn't beed stopped. Why can I believe any miracle 
occur?

The fact is, any heuristic change have a risk. because we can't know
all of the world use case. then, I don't think we must not change anything
nor we must not makes any mistake. I only want to surely care to keep
trackability.



> Even better: apply the patches and run some tests.  If you believe
> there are new failure modes then surely you can quickly prepare a
> testcase which demonstrates them.
> 
> Or just suggest a test case - I expect David will be able to test it.
> 
> Again: without hard, tangible engineering facts I cannot take comments
> such as the above into account.

OK. I also aim to provide good and productive information. But I also 
have requests.
Recently mainly Oleg pointed some race and heuristic failure. I don't
want your engineer ignore such bug report. please help bugfix too, please.
otherwise, I'll upset again.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
