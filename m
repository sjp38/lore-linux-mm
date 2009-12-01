Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 36AAC600309
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 23:14:25 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB14EMwW001785
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 1 Dec 2009 13:14:22 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8CFF845DE4F
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 13:14:22 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C2AC45DE54
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 13:14:22 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E5FB11DB803C
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 13:14:21 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 42E8EE18018
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 13:14:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/9] ksm: let shared pages be swappable
In-Reply-To: <Pine.LNX.4.64.0911301227530.24660@sister.anvils>
References: <20091130180452.5BF6.A69D9226@jp.fujitsu.com> <Pine.LNX.4.64.0911301227530.24660@sister.anvils>
Message-Id: <20091201125801.5C16.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  1 Dec 2009 13:14:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > btw, I'm not sure why bellow kmem_cache_zalloc() is necessary. Why can't we
> > use stack?
> 
> Well, I didn't use stack: partly because I'm so ashamed of the pseudo-vmas
> on the stack in mm/shmem.c, which have put shmem_getpage() into reports
> of high stack users (I've unfinished patches to deal with that); and
> partly because page_referenced_ksm() and try_to_unmap_ksm() are on
> the page reclaim path, maybe way down deep on a very deep stack.
> 
> But it's not something you or I should be worrying about: as the comment
> says, this is just a temporary hack, to present a patch which gets KSM
> swapping working in an understandable way, while leaving some corrections
> and refinements to subsequent patches.  This pseudo-vma is removed in the
> very next patch.

I see. thanks for kindly explanation :)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
