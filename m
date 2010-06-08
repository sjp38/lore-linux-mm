Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 64F0A6B01D4
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 15:27:55 -0400 (EDT)
Date: Tue, 8 Jun 2010 12:27:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 07/18] oom: filter tasks not sharing the same cpuset
Message-Id: <20100608122740.8f045c78.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1006081149320.18848@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006061524310.32225@chino.kir.corp.google.com>
	<20100608203342.7663.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1006081149320.18848@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010 11:51:32 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> Andrew, are you the maintainer for these fixes or is KOSAKI?

I am, thanks.  Kosaki-san, you're making this harder than it should be.
Please either ack David's patches or promptly work with him on
finalising them.

I realise that you have additional oom-killer patches but it's too
complex to try to work on two patch series concurrently.  So let's
concentrate on get David's work sorted out and merged and then please
rebase yours on the result.

I certainly don't have the time or inclination to go through two
patchsets and work out what the similarities and differences are so
I'll be concentrating on David's ones first.  The order in which we
do this doesn't really matter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
