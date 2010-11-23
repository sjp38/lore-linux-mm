Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 54AFE6B0092
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 02:17:02 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAN7Gxwp023817
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 23 Nov 2010 16:16:59 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3071445DE6E
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:16:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0AB7945DE4D
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:16:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E20211DB803A
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:16:58 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E4911DB8037
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:16:58 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [resend][PATCH 2/4] Revert "oom: deprecate oom_adj tunable"
In-Reply-To: <alpine.DEB.2.00.1011141333330.22262@chino.kir.corp.google.com>
References: <20101114135323.E00D.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011141333330.22262@chino.kir.corp.google.com>
Message-Id: <20101123160259.7B9C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue, 23 Nov 2010 16:16:57 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Sun, 14 Nov 2010, KOSAKI Motohiro wrote:
> 
> > No irrelevant. Your patch break their environment even though
> > they don't use oom_adj explicitly. because their application are using it.
> > 
> 
> The _only_ difference too oom_adj since the rewrite is that it is now 
> mapped on a linear scale rather than an exponential scale.  

_only_ mean don't ZERO different. Why do userland application need to rewrite?


> That's because 
> the heuristic itself has a defined range [0, 1000] that characterizes the 
> memory usage of the application it is ranking.  To show any breakge, you 
> would have to show how oom_adj values being used by applications are based 
> on a calculated value that prioritizes those tasks amongst each other.  
> With the exponential scale, that's nearly impossible because of the number 
> of arbitrary heuristics that were used before oom_adj were considered 
> (runtime, nice level, CAP_SYS_RAWIO, etc).

But, No people have agreed your powerfulness even though you talked about
the same explanation a lot of times.

Again, IF you need to [0 .. 1000] range, you can calculate it by your
application. current oom score can be get from /proc/pid/oom_score and
total memory can be get from /proc/meminfo. You shouldn't have break
anything.


> So don't talk about userspace breakage when you can't even describe it or 
> present a single usecase.

Huh? Remember! your feature have ZERO user.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
