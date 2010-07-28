Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 36A686B02A3
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 01:06:26 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6S56Nk8009392
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 28 Jul 2010 14:06:24 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 69ABD45DE51
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 14:06:23 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 492FF45DE4C
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 14:06:23 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E3DD01DB8012
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 14:06:22 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 60335E08002
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 14:06:22 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: PROBLEM: oom killer and swap weirdness on 2.6.3* kernels
In-Reply-To: <AANLkTin47_htYK8eV-6C4QkRK_U__qYeWX16Ly=YK-0w@mail.gmail.com>
References: <20100727200804.2F40.A69D9226@jp.fujitsu.com> <AANLkTin47_htYK8eV-6C4QkRK_U__qYeWX16Ly=YK-0w@mail.gmail.com>
Message-Id: <20100728135850.7A92.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Wed, 28 Jul 2010 14:06:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: dave b <db.pub.mail@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On 27 July 2010 21:14, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> On 27 July 2010 18:09, dave b <db.pub.mail@gmail.com> wrote:
> >> > On 27 July 2010 16:09, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> >>> > Do you mean the issue will be gone if disabling intel graphics?
> >> >>> It may be a general issue or it could just be specific :)
> >> >
> >> > I will try with the latest ubuntu and report how that goes (that will
> >> > be using fairly new xorg etc.) it is likely to be hidden issue just
> >> > with the intel graphics driver. However, my concern is that it isn't -
> >> > and it is about how shared graphics memory is handled :)
> >>
> >>
> >> Ok my desktop still stalled and no oom killer was invoked when I added
> >> swap to a live-cd of 10.04 amd64.
> >>
> >> *Without* *swap* *on* - the oom killer was invoked - here is a copy of it.
> >
> > This stack seems similar following bug. can you please try to disable intel graphics
> > driver?
> >
> > https://bugzilla.kernel.org/show_bug.cgi?id=14933
> 
> Ok I am not sure how to do that :)
> I could revert the patch and see if it 'fixes' this :)

Oops, no, revert is not good action. the patch is correct. 
probably my explanation was not clear. sorry.

I did hope to disable 'driver' (i.e. using vga), not disable the patch.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
