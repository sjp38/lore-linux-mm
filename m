Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 39D4A6B00F8
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 04:09:04 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n26991ZT012309
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 6 Mar 2009 18:09:01 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5807445DD72
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 18:09:01 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3750945DE50
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 18:09:01 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 36F711DB8037
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 18:09:01 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id DBD76E18001
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 18:09:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] kmemdup_from_user(): introduce
In-Reply-To: <20090306085731.GA4225@x200.localdomain>
References: <20090306003900.a031a914.akpm@linux-foundation.org> <20090306085731.GA4225@x200.localdomain>
Message-Id: <20090306180559.9BD9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  6 Mar 2009 18:09:00 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Fri, Mar 06, 2009 at 12:39:00AM -0800, Andrew Morton wrote:
> > On Fri, 06 Mar 2009 16:27:53 +0800 Li Zefan <lizf@cn.fujitsu.com> wrote:
> > 
> > > > Let's not add wrapper for every two lines that happen to be used
> > > > together.
> > > > 
> > > 
> > > Why not if we have good reasons? And I don't think we can call this
> > > "happen to" if there are 250+ of them?
> > 
> > The change is a good one.  If a reviewer (me) sees it then you know the
> > code's all right and the review effort becomes less - all you need to check
> > is that the call site is using IS_ERR/PTR_ERR and isn't testing for
> > NULL.  Less code, less chance for bugs.
> > 
> > Plus it makes kernel text smaller.
> > 
> > Yes, the name is a bit cumbersome.
> 
> Some do NUL-termination afterwards and allocate "len + 1", but copy "len".
> Some don't care.

if subsystem want string data, it should use strndup_user().
memdump don't need to care NUL-termination

In addition, also I often review various mm code and patch, I also like
this change.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
