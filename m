Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 543B58D0002
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 16:40:27 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o9PKeNHD031067
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 13:40:23 -0700
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by kpbe14.cbf.corp.google.com with ESMTP id o9PKeLdI000522
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 13:40:22 -0700
Received: by pzk36 with SMTP id 36so1171628pzk.11
        for <linux-mm@kvack.org>; Mon, 25 Oct 2010 13:40:21 -0700 (PDT)
Date: Mon, 25 Oct 2010 13:40:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [resend][PATCH 2/4] Revert "oom: deprecate oom_adj tunable"
In-Reply-To: <20101025122723.916D.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1010251338081.21737@chino.kir.corp.google.com>
References: <20101025122538.9167.A69D9226@jp.fujitsu.com> <20101025122723.916D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 25 Oct 2010, KOSAKI Motohiro wrote:

> oom_adj is not only used for kernel knob, but also used for
> application interface. Then, adding new knob is no good
> reason to deprecate it. Don't do stupid!
> 

NACK as a logical follow-up to my NACK for "oom: remove totalpage 
normalization from oom_badness()"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
