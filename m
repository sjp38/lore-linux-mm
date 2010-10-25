Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2473C6B0071
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 13:27:08 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
From: Roland McGrath <roland@redhat.com>
Subject: Re: [resend][PATCH 3/4] move cred_guard_mutex from task_struct to signal_struct
In-Reply-To: KOSAKI Motohiro's message of  Monday, 25 October 2010 12:28:40 +0900 <20101025122801.9170.A69D9226@jp.fujitsu.com>
References: <20101025122538.9167.A69D9226@jp.fujitsu.com>
	<20101025122801.9170.A69D9226@jp.fujitsu.com>
Message-Id: <20101025172657.A9EC9C9E3C@blackie.sf.frob.com>
Date: Mon, 25 Oct 2010 13:26:57 -0400 (EDT)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>
List-ID: <linux-mm.kvack.org>

This has my ACK if Oleg doesn't see any problems.

Thanks,
Roland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
