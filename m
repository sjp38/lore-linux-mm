Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 24C7A6B004A
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 03:24:01 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8L7NwJo015475
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 21 Sep 2010 16:23:58 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C7E5645DE55
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 16:23:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A14E045DE54
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 16:23:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 843E0E08003
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 16:23:57 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 34C361DB8038
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 16:23:57 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Problem with debugfs
In-Reply-To: <20100921061310.GA11526@localhost>
References: <20100921022112.GA10336@localhost> <20100921061310.GA11526@localhost>
Message-Id: <20100921162316.3C03.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 21 Sep 2010 16:23:56 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Kenneth <liguozhu@huawei.com>
Cc: kosaki.motohiro@jp.fujitsu.com, greg@kroah.com, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Hello, Mr. Greg,
> 
> I'm sorry I had not checked the git before sending my last mail.
> 
> For the problem I mention, consider this scenarios:
> 
> 1. mm/hwpoinson-inject.c create a debugfs file with
>    debugfs_create_u64("corrupt-filter-flags-mask", ...,
>    &hwpoison_filter_flags_mask)
> 2. hwpoison_filter_flags_mask is supposed to be protected by filp->priv->mutex
>    of this file when it is accessed from user space.
> 3. but when it is accessed from mm/memory-failure.c:hwpoison_filter_flags,
>    there is no way for the function to protect the operation (so it simply
>    ignore it). This may create a competition problem.
> 
> It should be a problem.
> 
> I'm sorry from my poor English skill.

I think your english is very clear :)
Let's cc hwpoison folks.


 - kosaki 


> 
> Best Regards
> Kenneth Lee
> 
> On Tue, Sep 21, 2010 at 10:21:12AM +0800, kenny wrote:
> > Hi, there,
> > 
> > I do not know who is the maintainer for debugfs now. But I think there is
> > problem with its API: It uses filp->priv->mutex to protect the read/write (to
> > the file) for the value of its attribute, but the mutex is not exported to the
> > API user.  Therefore, there is no way to protect its value when you directly
> > use the value in your module.
> > 
> > Is my understanding correct?
> > 
> > Thanks
> > 
> > 
> > Best Regards
> > Kenneth Lee
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
