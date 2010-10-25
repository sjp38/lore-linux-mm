Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9F3686B0087
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 13:48:09 -0400 (EDT)
Date: Mon, 25 Oct 2010 19:42:20 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [resend][PATCH 3/4] move cred_guard_mutex from task_struct to
	signal_struct
Message-ID: <20101025174220.GA21375@redhat.com>
References: <20101025122538.9167.A69D9226@jp.fujitsu.com> <20101025122801.9170.A69D9226@jp.fujitsu.com> <20101025172657.A9EC9C9E3C@blackie.sf.frob.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101025172657.A9EC9C9E3C@blackie.sf.frob.com>
Sender: owner-linux-mm@kvack.org
To: Roland McGrath <roland@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 10/25, Roland McGrath wrote:
>
> This has my ACK if Oleg doesn't see any problems.

I believe the patch is fine (it already has my reviewed-by).

Except: I am not sure about -stable. At least, this patch should
not go into the <2.6.35 kernels, it relies on misc changes which
changed the scope of task->signal. Before 2.6.35 almost any user
of ->cred_guard_mutex can race with exit and hit ->signal == NULL.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
