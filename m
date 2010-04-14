Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DFD4E6B021C
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 01:54:17 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3E5sFN1023493
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 14 Apr 2010 14:54:15 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A5D445DE4F
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 14:54:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C7BB45DE4E
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 14:54:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 113F41DB803C
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 14:54:15 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B934F1DB8038
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 14:54:14 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
In-Reply-To: <20100414054144.GH2493@dastard>
References: <20100414135945.2b0a1e0d.kamezawa.hiroyu@jp.fujitsu.com> <20100414054144.GH2493@dastard>
Message-Id: <20100414145056.D147.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 14 Apr 2010 14:54:14 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Wed, Apr 14, 2010 at 01:59:45PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Wed, 14 Apr 2010 11:40:41 +1000
> > Dave Chinner <david@fromorbit.com> wrote:
> > 
> > >  50)     3168      64   xfs_vm_writepage+0xab/0x160 [xfs]
> > >  51)     3104     384   shrink_page_list+0x65e/0x840
> > >  52)     2720     528   shrink_zone+0x63f/0xe10
> > 
> > A bit OFF TOPIC.
> > 
> > Could you share disassemble of shrink_zone() ?
> > 
> > In my environ.
> > 00000000000115a0 <shrink_zone>:
> >    115a0:       55                      push   %rbp
> >    115a1:       48 89 e5                mov    %rsp,%rbp
> >    115a4:       41 57                   push   %r15
> >    115a6:       41 56                   push   %r14
> >    115a8:       41 55                   push   %r13
> >    115aa:       41 54                   push   %r12
> >    115ac:       53                      push   %rbx
> >    115ad:       48 83 ec 78             sub    $0x78,%rsp
> >    115b1:       e8 00 00 00 00          callq  115b6 <shrink_zone+0x16>
> >    115b6:       48 89 75 80             mov    %rsi,-0x80(%rbp)
> > 
> > disassemble seems to show 0x78 bytes for stack. And no changes to %rsp
> > until retrun.
> 
> I see the same. I didn't compile those kernels, though. IIUC,
> they were built through the Ubuntu build infrastructure, so there is
> something different in terms of compiler, compiler options or config
> to what we are both using. Most likely it is the compiler inlining,
> though Chris's patches to prevent that didn't seem to change the
> stack usage.
> 
> I'm trying to get a stack trace from the kernel that has shrink_zone
> in it, but I haven't succeeded yet....

I also got 0x78 byte stack usage. Umm.. Do we discussed real issue now?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
