Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id BABF36B0071
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 15:07:50 -0500 (EST)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id oAUK7jEP017747
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 12:07:45 -0800
Received: from pxi9 (pxi9.prod.google.com [10.243.27.9])
	by hpaq12.eem.corp.google.com with ESMTP id oAUK7gdl024496
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 12:07:43 -0800
Received: by pxi9 with SMTP id 9so1594085pxi.37
        for <linux-mm@kvack.org>; Tue, 30 Nov 2010 12:07:42 -0800 (PST)
Date: Tue, 30 Nov 2010 12:07:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [resend][PATCH 2/4] Revert "oom: deprecate oom_adj tunable"
In-Reply-To: <20101130220221.832B.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1011301205510.12979@chino.kir.corp.google.com>
References: <20101123160259.7B9C.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011271737110.3764@chino.kir.corp.google.com> <20101130220221.832B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Nov 2010, KOSAKI Motohiro wrote:

> > Because NOTHING breaks with the new mapping.  Eight months later since 
> > this was initially proposed on linux-mm, you still cannot show a single 
> > example that depended on the exponential mapping of oom_adj.  I'm not 
> > going to continue responding to your criticism about this point since your 
> > argument is completely and utterly baseless.
> 
> No regression mean no break. Not single nor multiple. see?
> 

Nothing breaks.  If something did, you could respond to my answer above 
and provide a single example of a real-world example that broke as a 
result of the new linear mapping.

> All situation can be calculated on userland. User process can be know
> their bindings.
> 

Yes, but the proportional priority-based oom_score_adj values allow users 
to avoid recalculating and writing that value anytime a mempolicy 
attachment changes, its nodemask changes, it moves to another cpuset, its 
set of mems changes, its memcg attachment changes, its limit is modiifed, 
etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
