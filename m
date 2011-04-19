Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 12661900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 20:34:19 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 72EE03EE0BB
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 09:34:16 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1EC6645DE9A
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 09:34:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 005A345DE96
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 09:34:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DEB8E1DB804A
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 09:34:15 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C0B4E08001
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 09:34:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2] mempolicy: reduce references to the current
In-Reply-To: <1302847688-8076-1-git-send-email-namhyung@gmail.com>
References: <BANLkTinDFrbUNPnUmed2aBTu1_QHFQie-w@mail.gmail.com> <1302847688-8076-1-git-send-email-namhyung@gmail.com>
Message-Id: <20110419093421.9371.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 19 Apr 2011 09:34:14 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> Remove duplicated reference to the 'current' task using a local
> variable. Since refering the current can be a burden, it'd better
> cache the reference, IMHO. At least this saves some bytes on x86_64.
> 
>   $ size mempolicy-{old,new}.o
>      text    data    bss     dec     hex filename
>     25203    2448   9176   36827    8fdb mempolicy-old.o
>     25136    2448   9184   36768    8fa0 mempolicy-new.o
> 
> Signed-off-by: Namhyung Kim <namhyung@gmail.com>

But, dense stack usage is also performance good thing. Therefore your
patch benefit is not obvious. I have two request.

1) Please don't increase mess into no hot path. It's no worth.
2) Please mesure performance your box instead size command.

thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
