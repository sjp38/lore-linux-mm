Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 653ED6B003D
	for <linux-mm@kvack.org>; Sun,  5 Apr 2009 20:21:19 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n360Lak0022002
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 6 Apr 2009 09:21:37 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C6D445DE61
	for <linux-mm@kvack.org>; Mon,  6 Apr 2009 09:21:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 402F845DD79
	for <linux-mm@kvack.org>; Mon,  6 Apr 2009 09:21:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EE4831DB803C
	for <linux-mm@kvack.org>; Mon,  6 Apr 2009 09:21:35 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8CBB41DB803B
	for <linux-mm@kvack.org>; Mon,  6 Apr 2009 09:21:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH for -mm] getrusage: fill ru_maxrss value
In-Reply-To: <Pine.LNX.4.64.0904051736210.23536@blonde.anvils>
References: <20090405084902.GA4411@psychotron.englab.brq.redhat.com> <Pine.LNX.4.64.0904051736210.23536@blonde.anvils>
Message-Id: <20090406091825.44F0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  6 Apr 2009 09:21:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Jiri Pirko <jpirko@redhat.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, oleg@redhat.com, linux-mm@kvack.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

Hi

> I'm worrying particularly about the fork/exec issue you highlight.
> You're exemplary in providing your test programs, but there's a big
> omission: you don't mention that the first test, "./getrusage -lc",
> gives a very different result on Linux than you say it does on BSD -
> you say the BSD fork line is "fork: self 0 children 0", whereas
> I find my Linux fork line is "fork: self 102636 children 0".

FreeBSD update rusage at tick updating point. (I think all bsd do that)
Then, bsd displaing 0 is bsd's problem :)

Do I must change test program?

> So after that discrepancy, I can't tell what to expect.  Not that
> I can make any sense of BSD's "self 0" there - I don't know how
> you could present 0 there if this is related to hiwater_rss.
> 
> Now I'm seriously wondering if the ru_maxrss reported will generate
> more bugreports from people puzzled as to how it should behave,
> than help anyone in studying their process behaviour.
> 
> Sorry to be so negative after all this time: I genuinely hope others
> will spring up to defend your patch and illustrate my stupidity.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
