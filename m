Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2FB2B6B02A4
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 19:16:03 -0400 (EDT)
Date: Thu, 29 Jul 2010 16:08:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch -mm 1/2] oom: badness heuristic rewrite
Message-Id: <20100729160822.cd910c1b.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1007170307110.8730@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1007170307110.8730@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Nick Piggin <npiggin@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@in.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 17 Jul 2010 12:16:33 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> This a complete rewrite of the oom killer's badness() heuristic 

Any comments here, or are we ready to proceed?

Gimme those acked-bys, reviewed-bys and tested-bys, please!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
