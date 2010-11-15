Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C8C948D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 02:09:44 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAF79fHq003147
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 15 Nov 2010 16:09:41 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A99B845DE51
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 16:09:41 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8865745DE4F
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 16:09:41 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 72DFA1DB8038
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 16:09:41 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2AC0E1DB8043
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 16:09:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: fadvise DONTNEED implementation (or lack thereof)
In-Reply-To: <AANLkTim59Qx6TsvXnTBL5Lg6JorbGaqx3KsdBDWO04X9@mail.gmail.com>
References: <20101114140920.E013.A69D9226@jp.fujitsu.com> <AANLkTim59Qx6TsvXnTBL5Lg6JorbGaqx3KsdBDWO04X9@mail.gmail.com>
Message-Id: <20101115160413.BF0F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 15 Nov 2010 16:09:37 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Ben Gamari <bgamari.foss@gmail.com>, linux-kernel@vger.kernel.org, rsync@lists.samba.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

> > Because we have an alternative solution already. please try memcgroup :)
> 
> I think memcg could be a solution of them but fundamental solution is
> that we have to cure it in VM itself.
> I feel it's absolutely absurd to enable and use memcg for amending it.
> 
> I wonder what's the problem in Peter's patch 'drop behind'.
> http://www.mail-archive.com/linux-kernel@vger.kernel.org/msg179576.html
> 
> Could anyone tell me why it can't accept upstream?

I don't know the reason. And this one looks reasonable to me. I'm curious the above 
patch solve rsync issue or not. 
Minchan, have you tested it yourself?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
