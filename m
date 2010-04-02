Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 256E96B01FA
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 07:32:04 -0400 (EDT)
Date: Fri, 2 Apr 2010 13:30:23 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch -mm 0/5] oom: fixes and cleanup
Message-ID: <20100402113023.GB4432@redhat.com>
References: <alpine.DEB.2.00.1004011240370.13247@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1004011240370.13247@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 04/01, David Rientjes wrote:
>
> This patchset fixes a couple of issues with the oom killer, namely
> tasklist_lock locking requirements and sending SIGKILLs to already
> exiting tasks.  It also cleans up a couple functions, __oom_kill_task()
> and oom_badness().

The whole series looks good to me.

Thanks David.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
