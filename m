Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 093636B01E1
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 16:27:38 -0400 (EDT)
Date: Tue, 8 Jun 2010 22:26:11 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch 06/18] oom: avoid sending exiting tasks a SIGKILL
Message-ID: <20100608202611.GA11284@redhat.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061524190.32225@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1006061524190.32225@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

To clarify, I am not going to review this patch ;)
As I said many times I can only understand what oom_kill.c does,
but now why.

On 06/06, David Rientjes wrote:
>
> It's unnecessary to SIGKILL a task that is already PF_EXITING

This probably needs some explanation. PF_EXITING doesn't necessarily
mean this process is exiting.

> and can
> actually cause a NULL pointer dereference of the sighand

Yes. Another reason to avoid force_sig().

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
