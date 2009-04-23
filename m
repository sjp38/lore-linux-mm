Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6D8E66B0115
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 20:47:26 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3N0m9bO002767
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 23 Apr 2009 09:48:09 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id ECA2545DD76
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 09:48:08 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 91A0C45DD79
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 09:48:08 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F4591DB8016
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 09:48:08 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 207301DB801A
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 09:48:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [Patch] mm tracepoints update - use case.
In-Reply-To: <1240428151.11613.46.camel@dhcp-100-19-198.bos.redhat.com>
References: <1240402037.4682.3.camel@dhcp47-138.lab.bos.redhat.com> <1240428151.11613.46.camel@dhcp-100-19-198.bos.redhat.com>
Message-Id: <20090423092933.F6E9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Thu, 23 Apr 2009 09:48:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Larry Woodman <lwoodman@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Ingo Molnar <mingo@elte.hu>, =?ISO-2022-JP?B?RnIbJEJxRXFTGyhCaWM=?= Weisbecker <fweisbec@gmail.com>, Li Zefan <lizf@cn.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, eduard.munteanu@linux360.ro, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, rostedt@goodmis.org
List-ID: <linux-mm.kvack.org>

> On Wed, 2009-04-22 at 08:07 -0400, Larry Woodman wrote:
> > On Wed, 2009-04-22 at 11:57 +0200, Ingo Molnar wrote:
> > > * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > > In past thread, Andrew pointed out bare page tracer isn't useful. 
> > > 
> > > (do you have a link to that mail?)
> > > 
> > > > Can you make good consumer?
> > 
> > I will work up some good examples of what these are useful for.  I use
> > the mm tracepoint data in the debugfs trace buffer to locate customer
> > performance problems associated with memory allocation, deallocation,
> > paging and swapping frequently, especially on large systems.
> > 
> > Larry
> 
> Attached is an example of what the mm tracepoints can be used for:

I have some comment.

1. Yes, current zone_reclaim have strange behavior. I plan to fix
   some bug-like bahavior.
2. your scenario only use the information of "zone_reclaim called".
   function tracer already provide it.
3. but yes, you are going to proper direction. we definitely need
   some fine grained tracepoint in this area. we are welcome to you.
   but in my personal feeling, your tracepoint have worthless argument
   a lot. we need more good information.
   I think I can help you in this area. I hope to work together.







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
