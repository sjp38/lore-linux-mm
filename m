Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E4AA56B007B
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 02:57:23 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8G6vLNZ016074
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 16 Sep 2010 15:57:21 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 872DE45DE58
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 15:57:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5769B45DE51
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 15:57:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id F1B38E08004
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 15:57:18 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CE88EE18009
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 15:57:17 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] oom: remove totalpage normalization from oom_badness()
In-Reply-To: <alpine.DEB.2.00.1009152300380.25200@chino.kir.corp.google.com>
References: <20100916145452.3BB1.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1009152300380.25200@chino.kir.corp.google.com>
Message-Id: <20100916155413.3BC0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 16 Sep 2010 15:57:16 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, oss-security@lists.openwall.com, Solar Designer <solar@openwall.com>, Kees Cook <kees.cook@canonical.com>, Al Viro <viro@zeniv.linux.org.uk>, Oleg Nesterov <oleg@redhat.com>, Neil Horman <nhorman@tuxdriver.com>, linux-fsdevel@vger.kernel.org, pageexec@freemail.hu, Brad Spengler <spender@grsecurity.net>, Eugene Teo <eugene@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Thu, 16 Sep 2010, KOSAKI Motohiro wrote:
> 
> > Current oom_score_adj is completely broken because It is strongly bound
> > google usecase and ignore other all.
> > 
> 
> We've talked about this issue three times already.  The last two times 
> you've sent a revert patch, you failed to followup on the threads:
> 
> 	http://marc.info/?t=128272938200002
> 	http://marc.info/?t=128324705200002
> 
> And now you've gone above Andrew, who is the maintainer of this code, and 
> straight to Linus.  Between that and your failure to respond to my answers 
> to your questions, I'm really stunned at how unprofessional you've handled 
> this.

Selfish must die. you failed to persuade to me. and I havgen't get anyone's objection.
Then, I don't care your ugly whining.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
