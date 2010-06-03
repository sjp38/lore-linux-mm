Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3EF7F6B01AF
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 19:15:50 -0400 (EDT)
Date: Thu, 3 Jun 2010 16:15:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch -mm 08/18] oom: badness heuristic rewrite
Message-Id: <20100603161532.8e41b42a.akpm@linux-foundation.org>
In-Reply-To: <20100603104314.723D.A69D9226@jp.fujitsu.com>
References: <20100602222347.F527.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1006021421540.32666@chino.kir.corp.google.com>
	<20100603104314.723D.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu,  3 Jun 2010 12:07:50 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> In other word, I'm sure I'll continue to get OOM bug report in future.

You must have some reason for believing that.  Please share it with us.

Even better: apply the patches and run some tests.  If you believe
there are new failure modes then surely you can quickly prepare a
testcase which demonstrates them.

Or just suggest a test case - I expect David will be able to test it.

Again: without hard, tangible engineering facts I cannot take comments
such as the above into account.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
