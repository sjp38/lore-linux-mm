Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0374D600044
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 00:53:27 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6R4kiVh018593
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 27 Jul 2010 13:46:44 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 84BD245DE4D
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 13:46:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 62F9C45DE4E
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 13:46:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FDC51DB8038
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 13:46:44 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 113951DB803B
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 13:46:44 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: PROBLEM: oom killer and swap weirdness on 2.6.3* kernels
In-Reply-To: <AANLkTi=Aswf+Hp+qfsC2sCo32hU3E2D4zt3-R35BZ=MC@mail.gmail.com>
References: <alpine.DEB.2.00.1007261510320.2993@chino.kir.corp.google.com> <AANLkTi=Aswf+Hp+qfsC2sCo32hU3E2D4zt3-R35BZ=MC@mail.gmail.com>
Message-Id: <20100727134431.2F11.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue, 27 Jul 2010 13:46:43 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: dave b <db.pub.mail@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On 27 July 2010 08:12, David Rientjes <rientjes@google.com> wrote:
> > On Tue, 27 Jul 2010, dave b wrote:
> >
> >> Actually it turns out on 2.6.34.1 I can trigger this issue. What it
> >> really is, is that linux doesn't invoke the oom killer when it should
> >> and kill something off. This is *really* annoying.
> >>
> >
> > I'm not exactly sure what you're referring to, it's been two months and
> > you're using a new kernel and now you're saying that the oom killer isn't
> > being utilized when the original problem statement was that it was killing
> > things inappropriately?
> 
> Sorry about the timespan :(
> Well actually it is the same issue. Originally the oom killer wasn't
> being invoked and now the problem is still it isn't invoked - it
> doesn't come and kill things - my desktop just sits :)
> I have since replaced the hard disk - which I thought could be the
> issue. I am thinking that because I have shared graphics not using KMS
> - with intel graphics - this may be the root of the cause.

Do you mean the issue will be gone if disabling intel graphics?
if so, we need intel graphics driver folks help. sorry, linux-mm folks don't
know intel graphics detail.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
