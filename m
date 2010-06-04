Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E49E06B01B6
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 05:44:58 -0400 (EDT)
Date: Fri, 4 Jun 2010 11:43:32 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch -mm 08/18] oom: badness heuristic rewrite
Message-ID: <20100604094332.GA8569@redhat.com>
References: <20100601163627.245D.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006011140110.32024@chino.kir.corp.google.com> <20100602225252.F536.A69D9226@jp.fujitsu.com> <20100603161030.074d9b98.akpm@linux-foundation.org> <20100604085347.80c7b43f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100604085347.80c7b43f.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 06/04, KAMEZAWA Hiroyuki wrote:
>
> On Thu, 3 Jun 2010 16:10:30 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
>
> But this series includes both of bug fixes and new features at random.
> Then, a small bugfixes, which doens't require refactoring, seems to do that.
> That's irritating guys (at least me)

Me too.

And Kosaki tries to fix these long-standing (and obvious) bugs first,
before refactoring.

So far (iiuc) David technically disagrees with the single patch which
removes the PF_EXITING check. OK, probably it needs more discussion
(once again: I can't judge, but I understand why Kosaki removed it).

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
