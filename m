Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2006F6B00E2
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 02:37:16 -0500 (EST)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n267bDZu011012
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 6 Mar 2009 16:37:13 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A5B0A45DE51
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 16:37:13 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8367C45DE50
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 16:37:13 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 331B11DB803E
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 16:37:13 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DCFA81DB803A
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 16:37:12 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] kmemdup_from_user(): introduce
In-Reply-To: <20090306072328.GL22605@hack.private>
References: <49B0CAEC.80801@cn.fujitsu.com> <20090306072328.GL22605@hack.private>
Message-Id: <20090306163600.3469.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  6 Mar 2009 16:37:12 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Americo Wang <xiyou.wangcong@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > /**
> >+ * kmemdup_from_user - duplicate memory region from user space
> >+ *
> >+ * @src: source address in user space
> >+ * @len: number of bytes to copy
> >+ * @gfp: GFP mask to use
> >+ */
> >+void *kmemdup_from_user(const void __user *src, size_t len, gfp_t gfp)
> >+{
> >+	void *p;
> >+
> >+	p = kmalloc_track_caller(len, gfp);
> 
> 
> Well, you use kmalloc_track_caller, instead of kmalloc as you showed
> above. :) Why don't you mention this?

kmalloc() wrapper function must use kmalloc_track_caller().
his code is right.

if not, kmalloc tracking feature is breaked.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
