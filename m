Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1CE606B0071
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 09:18:31 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
From: Roland McGrath <roland@redhat.com>
Subject: Re: [resend][PATCH 3/4] move cred_guard_mutex from task_struct to signal_struct
In-Reply-To: KOSAKI Motohiro's message of  Tuesday, 26 October 2010 22:04:50 +0900 <20101026220314.B7DD.A69D9226@jp.fujitsu.com>
References: <20101025174220.GA21375@redhat.com>
	<20101025175113.963CCC9E3C@blackie.sf.frob.com>
	<20101026220314.B7DD.A69D9226@jp.fujitsu.com>
Message-Id: <20101026131826.5B262C9E36@blackie.sf.frob.com>
Date: Tue, 26 Oct 2010 09:18:26 -0400 (EDT)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Because [4/4] depend on [3/4] and I hope to backport it. Do you dislike it
> too?

Ah, OK.  That is indeed a fix for an important bug.  Not knowing the mm
code very well, I'm not in a position to judge whether it's safe enough
for a -stable stream or not.  If it is and it could be done safely
without relying on 3/4, that would seem safer to me, but it is not a
strong opinion.


Thanks,
Roland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
