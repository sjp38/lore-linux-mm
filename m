Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3EB6D6B01CC
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 19:47:30 -0400 (EDT)
Date: Tue, 8 Jun 2010 16:47:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch -mm 08/18] oom: badness heuristic rewrite
Message-Id: <20100608164722.9724baf9.akpm@linux-foundation.org>
In-Reply-To: <20100608172820.7645.A69D9226@jp.fujitsu.com>
References: <20100604195328.72D9.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1006041333550.27219@chino.kir.corp.google.com>
	<20100608172820.7645.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue,  8 Jun 2010 20:41:55 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> of the patch don't concentrate one thing. 2) That is strongly concentrate 
> "what and how to implement". But reviewers don't want such imformation so much 
> because they can read C language. reviewers need following information.
>   - background
>   - why do the author choose this way?
>   - why do the author choose this default value?
>   - how to confirm your concept and implementation correct?
>   - etc etc
> 
> thus, reviewers can trace the author thinking and makes good advise and judgement.
> example in this case, you wrote
>  - default threshold is 1000
>  - only accumurate 1st generation execve children
>  - time threshold is a second
> 
> but not wrote why? mess sentence hide such lack of document. then, I usually enforce
> a divide, because a divide naturally reduce to "which place change" document and 
> expose what lacking. 
> 
> Now I haven't get your intention. no test suite accelerate to can't get
> author think which workload is a problem workload.

hey, you're starting to sound like me.

>
> ...
>
> David, do you know other kernel engineer spent how much time for understanding
> a real workload and dialog various open source community and linux user company
> and user group?
> 
> At least, All developers must make _effort_ to spent some time to investigate 
> userland use case when they want to introduce new feature and incompatibility.
> Almost developers do. please read various new feature git log. few commit log
> are ridiculous quiet (probably the author bother cut-n-paste from ML bug report)
> but almost are wrote what is problem.
> thus, we can double check the problem and the code are matched correctly.
> 
> And, if you can't test your patch on various platform, at least you must to
> write theorical background of your patch. it definitely help each are engineer
> confirm your patch don't harm their area. However, for principal, if you
> want to introduce any imcompatibility, you must investigate how much affect this.
> 
> remark: if you think you need mathematical proof or 100% coveraged proof,
> it's not correct. you don't need such impossible work. We just require to
> confirm you investigate and consider enough large coverage.
> 
> Usually, the author of small patch aren't required this. because reviewers can
> think affected use-case from the code. almost reviewer have much use case knowledge
> than typical kernel developers. but now, you are challenging full
> of rewrite. We don't have enough information to finish reviewing.
> 
> Last of all, I've send various review result by another mail. Can you please
> read it?
> 

I think I'm beginning to understand your concerns with these patches. 
Finally.

Yes, it's a familiar one.  I do fairly commonly see patches where the
description can be summarised as "change lots and lots of stuff to no
apparent end" and one does have to push and poke to squeeze out the
thinking and the reasons.  It's a useful exercise and will sometimes
cause the originator to have a rethink, and sometimes reveals that it
just wasn't a good change.

Maybe if we'd been more diligent about all this around 2.6.12, we
wouldn't have wrecked dirty-page writeout off the tail of the LRU. 
Which is STILL wrecked, btw.

I think I read somewhere in one of David's emails that some of this
code has been floating around in Google for several years?  If so, the
reasons for making certain changes might even be lost and forgotten.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
