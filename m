Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A4D216B01DD
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 17:14:03 -0400 (EDT)
Date: Tue, 8 Jun 2010 14:13:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 10/18] oom: enable oom tasklist dump by default
Message-Id: <20100608141342.114156ac.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1006061525150.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006061525150.32225@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 6 Jun 2010 15:34:35 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> The oom killer tasklist dump, enabled with the oom_dump_tasks sysctl, is
> very helpful information in diagnosing why a user's task has been killed.
> It emits useful information such as each eligible thread's memory usage
> that can determine why the system is oom, so it should be enabled by
> default.

Unclear.  On a large system the poor thing will now spend half an hour
squirting junk out the diagnostic port.  Probably interspersed with the
occasional whine from the softlockup detector.  And for many
applications, spending a long time stuck in the kernel printing
diagnostics is equivalent to an outage.

I guess people can turn it off again if this happens, but they'll get
justifiably grumpy at us.  I wonder if this change is too
developer-friendly and insufficiently operator-friendly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
