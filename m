Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 64BF66B02A3
	for <linux-mm@kvack.org>; Mon, 12 Jul 2010 17:48:05 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id o6CLm1SY002403
	for <linux-mm@kvack.org>; Mon, 12 Jul 2010 14:48:02 -0700
Received: from pzk30 (pzk30.prod.google.com [10.243.19.158])
	by kpbe12.cbf.corp.google.com with ESMTP id o6CLlx2D020005
	for <linux-mm@kvack.org>; Mon, 12 Jul 2010 14:48:00 -0700
Received: by pzk30 with SMTP id 30so1220354pzk.1
        for <linux-mm@kvack.org>; Mon, 12 Jul 2010 14:47:59 -0700 (PDT)
Date: Mon, 12 Jul 2010 14:47:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: FYI: mmap_sem OOM patch
In-Reply-To: <20100708200324.CD4B.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1007121446500.8468@chino.kir.corp.google.com>
References: <20100708195421.CD48.A69D9226@jp.fujitsu.com> <1278586921.1900.67.camel@laptop> <20100708200324.CD4B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Divyesh Shah <dpshah@google.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Thu, 8 Jul 2010, KOSAKI Motohiro wrote:

> I disagree. __GFP_NOFAIL mean this allocation failure can makes really
> dangerous result. Instead, OOM-Killer should try to kill next process.
> I think.
> 

That's not what happens, __alloc_pages_high_priority() will loop forever 
for __GFP_NOFAIL, the oom killer is never recalled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
