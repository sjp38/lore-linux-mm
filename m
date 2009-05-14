Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4E7BB6B018D
	for <linux-mm@kvack.org>; Thu, 14 May 2009 04:53:44 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4E8sWRj015813
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 14 May 2009 17:54:32 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 79C9F45DE5F
	for <linux-mm@kvack.org>; Thu, 14 May 2009 17:54:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 409F945DE5A
	for <linux-mm@kvack.org>; Thu, 14 May 2009 17:54:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C6461DB8052
	for <linux-mm@kvack.org>; Thu, 14 May 2009 17:54:30 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 099D11DB8044
	for <linux-mm@kvack.org>; Thu, 14 May 2009 17:54:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: kernel BUG at mm/slqb.c:1411!
In-Reply-To: <1242289830.21646.5.camel@penberg-laptop>
References: <20090513173758.2f3d2a50.minchan.kim@barrios-desktop> <1242289830.21646.5.camel@penberg-laptop>
Message-Id: <20090514175332.9B7B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 14 May 2009 17:54:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

> On Wed, 2009-05-13 at 17:37 +0900, Minchan Kim wrote:
> > On Wed, 13 May 2009 16:42:37 +0900 (JST)
> > KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > 
> > Hmm. I don't know slqb well.
> > So, It's just my guess. 
> > 
> > We surely increase l->nr_partial in  __slab_alloc_page.
> > In between l->nr_partial++ and call __cache_list_get_page, Who is decrease l->nr_partial again.
> > After all, __cache_list_get_page return NULL and hit the VM_BUG_ON.
> > 
> > Comment said :
> > 
> >         /* Protects nr_partial, nr_slabs, and partial */
> >   spinlock_t    page_lock;
> > 
> > As comment is right, We have to hold the l->page_lock ?
> 
> Makes sense. Nick? Motohiro-san, can you try this patch please?

This issue is very rarely. please give me one night.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
