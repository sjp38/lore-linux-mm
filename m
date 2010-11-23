Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4EE036B0088
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 02:19:56 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAN7JrYL025092
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 23 Nov 2010 16:19:54 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A410445DE57
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:19:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F3A245DE4D
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:19:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 617DC1DB803E
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:19:53 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F57A1DB8037
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:19:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch] mm: vmscan implement per-zone shrinkers
In-Reply-To: <4CE36652.50305@leadcoretech.com>
References: <AANLkTi==W_KHL3pd8Cq=ojV=aAAOxi4c=ZkHSednOVyH@mail.gmail.com> <4CE36652.50305@leadcoretech.com>
Message-Id: <20101123161915.7BAD.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 23 Nov 2010 16:19:52 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Figo.zhang" <zhangtianfei@leadcoretech.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Anca Emanuel <anca.emanuel@gmail.com>, Nick Piggin <npiggin@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> >>>>
> >>>> hi KOSAKI Motohiro,
> >>>>
> >>>> is it any test suite or test scripts for test page-reclaim performance?
> >>>>
> >>>> Best,
> >>>> Figo.zhang
> >>>>
> >>>
> >>> There is http://www.phoronix.com
> >>
> >> it is not focus on page-reclaim test, or specially for MM.
> >>>
> >>
> >>
> > 
> > If you want some special test, you have to ask Michael Larabel for that.
> > http://www.phoronix-test-suite.com/
> 
> yes, i see, the phoronix-test-suite is test such as ffmpeg, games. not
> focus on MM.

Hi Figo,

I agree with Anca. Nick's patch will change almost VM behavior. then,
generic performance test suit is better than supecific one.

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
