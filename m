Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3CBB88D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 01:20:21 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 9A6733EE0BC
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 15:20:17 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8439545DE5B
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 15:20:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DB1A45DE58
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 15:20:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FF76E08002
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 15:20:17 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2992C1DB803A
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 15:20:17 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 5/6] proc: make check_mem_permission() return an mm_struct on success
In-Reply-To: <1299631343-4499-6-git-send-email-wilsons@start.ca>
References: <1299631343-4499-1-git-send-email-wilsons@start.ca> <1299631343-4499-6-git-send-email-wilsons@start.ca>
Message-Id: <20110309151900.0403.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  9 Mar 2011 15:20:16 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Wilson <wilsons@start.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>, Roland McGrath <roland@redhat.com>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Ingo Molnar <mingo@elte.hu>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org

> This change allows us to take advantage of access_remote_vm(), which in turn
> enables a secure mem_write() implementation.
> 
> The previous implementation of mem_write() was insecure since the target task
> could exec a setuid-root binary between the permission check and the actual
> write.  Holding a reference to the target mm_struct eliminates this
> vulnerability.
> 
> Signed-off-by: Stephen Wilson <wilsons@start.ca>

OK, I like this idea. So, I suppose you will resend newer version as applied Al's
comment and I'll be able to ack this.

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
