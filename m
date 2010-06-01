Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5676F6B01D6
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:45:03 -0400 (EDT)
Date: Tue, 1 Jun 2010 22:43:42 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch -mm 13/18] oom: avoid race for oom killed tasks
	detaching mm prior to exit
Message-ID: <20100601204342.GC20732@redhat.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com> <alpine.DEB.2.00.1006010016460.29202@chino.kir.corp.google.com> <20100601164026.2472.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006011158230.32024@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1006011158230.32024@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 06/01, David Rientjes wrote:
>
> No, it applies to mmotm-2010-05-21-16-05 as all of these patches do. I
> know you've pushed Oleg's patches

(plus other fixes)

> but they are also included here so no
> respin is necessary unless they are merged first (and I think that should
> only happen if Andrew considers them to be rc material).

Well, I disagree.

I think it is always better to push the simple bugfixes first, then
change/improve the logic.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
