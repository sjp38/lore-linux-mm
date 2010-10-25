Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2ADCA6B0085
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 16:38:10 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o9PKc2HD018873
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 13:38:05 -0700
Received: from gxk23 (gxk23.prod.google.com [10.202.11.23])
	by kpbe11.cbf.corp.google.com with ESMTP id o9PKblJn027289
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 13:38:01 -0700
Received: by gxk23 with SMTP id 23so2552086gxk.5
        for <linux-mm@kvack.org>; Mon, 25 Oct 2010 13:37:57 -0700 (PDT)
Date: Mon, 25 Oct 2010 13:37:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [resend][PATCH 1/4] oom: remove totalpage normalization from
 oom_badness()
In-Reply-To: <20101025122538.9167.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1010251336080.21737@chino.kir.corp.google.com>
References: <20101025122538.9167.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 25 Oct 2010, KOSAKI Motohiro wrote:

> Current oom_score_adj is completely broken because It is strongly bound
> google usecase and ignore other all.
> 

NACK.

Same response as the previous three times this patch has been proposed:

	http://marc.info/?t=128461666500001
	http://marc.info/?t=128324705200002
	http://marc.info/?t=128272938200002

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
