Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB34HqvL009128
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 3 Dec 2008 13:17:52 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CCB7C45DD7F
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 13:17:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F66445DD7C
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 13:17:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CE5D1DB8043
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 13:17:51 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FBFA1DB803E
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 13:17:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH][V6]make get_user_pages interruptible
In-Reply-To: <604427e00812021957m44549252k21e1b617ba9e78c3@mail.gmail.com>
References: <20081203111440.1D35.KOSAKI.MOTOHIRO@jp.fujitsu.com> <604427e00812021957m44549252k21e1b617ba9e78c3@mail.gmail.com>
Message-Id: <20081203131522.1D41.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  3 Dec 2008 13:17:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Oleg Nesterov <oleg@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Paul Menage <menage@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>


> > more unfortunately, this patch break kernel compatibility.
> > To read /proc file invoke calling get_user_page().
> > however, "man 2 read" doesn't describe ERESTARTSYS.
> yeah, that seems to be right..
> >
> > IOW, this patch can break /proc reading user application.
> >
> > May I ask why fatal_signal_pending(tsk) is needed ?
> > at least, you need to cc to linux-api@vger.kernel.org IMHO.
> all the problems seems to be caused by the fatal_signal_pending(tsk),
> i can either make the change like
> if (fatal_signal_pending(tsk))
>    return i ? i : EINTR
> 
> or remove the check for fatal_signal_pending(tsk) which is mainly used in
> the case you mentioned above. Afterward, the intial point of the patch is to
> avoid proccess hanging in the mlock (for example) under memory
> pressure while it has SIGKILL pending. Now sounds to me the second option is
> better. any comments?

it seems both reasonable.
in my personal feeling, I like simple removing than EINTR.



> > Am I talking about pointless?
> thanks for comments. :-)

Could you please cc to me at posting v7.
maybe, I can ack.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
