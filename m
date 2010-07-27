Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 353CF600044
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 02:09:38 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6R69Yul019886
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 27 Jul 2010 15:09:34 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E904C45DE50
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 15:09:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C793B45DE4E
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 15:09:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id ADA271DB803C
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 15:09:33 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E5401DB8038
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 15:09:33 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: PROBLEM: oom killer and swap weirdness on 2.6.3* kernels
In-Reply-To: <AANLkTimdLbwvRNU09s+LfauREBaxyXBUE5jSmwnpCj8e@mail.gmail.com>
References: <20100727134431.2F11.A69D9226@jp.fujitsu.com> <AANLkTimdLbwvRNU09s+LfauREBaxyXBUE5jSmwnpCj8e@mail.gmail.com>
Message-Id: <20100727150138.2F20.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue, 27 Jul 2010 15:09:32 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: dave b <db.pub.mail@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > Do you mean the issue will be gone if disabling intel graphics?
> > if so, we need intel graphics driver folks help. sorry, linux-mm folks don't
> > know intel graphics detail.
> 
> Well the only other system I have running the 2.6.34.1 kernel atm is
> an arm based system.
> I originally sent this to the kernel list and was told I should
> probably forward it to the mm list.
> It may be a general issue or it could just be specific :)

Hmm.. I'm puzzled 8-)

I don't understand why other all people can't reproduce your issue
even though your reproduce program is very simple.

So, I'm guessing there is hidden reproduce condition. but I have no
idea to find it.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
