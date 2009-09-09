Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CF95D6B004D
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 19:17:25 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n89NHTpg006033
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 10 Sep 2009 08:17:29 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0068145DE4F
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 08:17:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D41A21EF081
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 08:17:28 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B3D6C1DB803A
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 08:17:28 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DA7FE08001
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 08:17:28 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH for -mm] getrusage: fill ru_maxrss value
In-Reply-To: <20090909134643.5479b09e.akpm@linux-foundation.org>
References: <20090907115430.6C16.A69D9226@jp.fujitsu.com> <20090909134643.5479b09e.akpm@linux-foundation.org>
Message-Id: <20090910081020.9CAE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 10 Sep 2009 08:17:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, hugh@veritas.com, jpirko@redhat.com, linux-kernel@vger.kernel.org, oleg@redhat.com, linux-mm@kvack.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

> On Mon,  7 Sep 2009 11:58:36 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > Grr, my fault.
> > > I recognize it. sorry.
> > 
> > I've finished my long pending homework ;)
> > 
> > Andrew, can you please replace following patch with getrusage-fill-ru_maxrss-value.patch
> > and getrusage-fill-ru_maxrss-value-update.patch?
> > 
> > 
> > 
> > ChangeLog
> >  ===============================
> >   o Merge getrusage-fill-ru_maxrss-value.patch and getrusage-fill-ru_maxrss-value-update.patch
> >   o rewrote test programs (older version hit FreeBSD bug and it obfuscate testcase intention, thanks Hugh)
> 
> The code changes are unaltered, so I merely updated the changelog.

I see. thanks.


> The changelog had lots of ^------- lines in it.  But those are
> conventionally the end-of-changelog separator so I rewrote them to
> ^=======

sorry, I have stupid question.
I thought "--" and "---" have special meaning. but other length "-" are safe.
Is this incorrect?

or You mean it's easy confusing bad style?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
