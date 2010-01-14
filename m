Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 11E896B006A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 03:17:45 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0E8HgRn000353
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 14 Jan 2010 17:17:42 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6730E2AEAA2
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 17:17:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 095321EF082
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 17:17:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DF6851DB8038
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 17:17:37 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6106EE08004
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 17:17:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v5] add MAP_UNLOCKED mmap flag
In-Reply-To: <20100114080117.GL18808@redhat.com>
References: <20100114162327.673E.A69D9226@jp.fujitsu.com> <20100114080117.GL18808@redhat.com>
Message-Id: <20100114170247.6747.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 14 Jan 2010 17:17:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> > Hmm..
> > Your answer didn't match I wanted.
> Then I don't get what you want.

I want to know the benefit of the patch for patch reviewing.


> > few additional questions.
> > 
> > - Why don't you change your application? It seems natural way than kernel change.
> There is no way to change my application and achieve what I've described
> in a multithreaded app.

Then, we don't recommend to use mlockall(). I don't hope to hear your conclusion,
it is not objectivization. I hope to hear why you reached such conclusion.


> > - Why do you want your virtual machine have mlockall? AFAIK, current majority
> >   virtual machine doesn't.
> It is absolutely irrelevant for that patch, but just because you ask I
> want to measure the cost of swapping out of a guest memory.

No. if you stop to use mlockall, the issue is vanished.


> > - If this feature added, average distro user can get any benefit?
> > 
> ?! Is this some kind of new measure? There are plenty of much more
> invasive features that don't bring benefits to an average distro user.
> This feature can bring benefit to embedded/RT developers.

I mean who get benifit?


> > I mean, many application developrs want to add their specific feature
> > into kernel. but if we allow it unlimitedly, major syscall become
> > the trushbox of pretty toy feature soon.
> > 
> And if application developer wants to extend kernel in a way that it
> will be possible to do something that was not possible before why is
> this a bad thing? I would agree with you if for my problem was userspace
> solution, but there is none. The mmap interface is asymmetric in regards
> to mlock currently. There is MAP_LOCKED, but no MAP_UNLOCKED. Why
> MAP_LOCKED is useful then?

Why? Because this is formal LKML reviewing process. I'm reviewing your
patch for YOU.

If there is no objective reason, I don't want to continue reviewing.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
