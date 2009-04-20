Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9CC8C5F0001
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 03:58:20 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3K7xDG8013169
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 20 Apr 2009 16:59:14 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C28EE45DE4E
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 16:59:13 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A188745DE4F
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 16:59:13 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6960FE08007
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 16:59:13 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 18425E08003
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 16:59:13 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Does get_user_pages_fast lock the user pages in memory in my case?
In-Reply-To: <49EC0A24.6060307@gmail.com>
References: <20090420141710.2509.A69D9226@jp.fujitsu.com> <49EC0A24.6060307@gmail.com>
Message-Id: <20090420165529.61AB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 20 Apr 2009 16:59:12 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> http://v4l2spec.bytesex.org/spec/r13696.htm
> shows the vidioc_reqbufs(). It determines the method of IO : "Memory 
> Mapping or User Pointer I/O"
> 
> The application developers can support any methodes of the Two, there is 
> no mandatory request to realize
> both methods.   For example, the Mplayer only support the "memory 
> maping" method ,and it does't support the "user pointer",
> while the VLC supports both.

I greped VIDIOC_REQBUFS on current tree.
Almost driver has following check.

        if (rb->memory != V4L2_MEMORY_MMAP)
		return -EINVAL;

IOW, almost one don't provide V4L2_MEMORY_USERPTR method.
Thus, I think any userland application don't want use V4L2_MEMORY_USERPTR.
I recommend you also return -EINVAL.

I think we can't implement V4L2_MEMORY_USERPTR properly.
it is mistake by specification.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
