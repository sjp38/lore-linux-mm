Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E2EFD8D0039
	for <linux-mm@kvack.org>; Sun,  6 Mar 2011 07:04:05 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 548233EE0AE
	for <linux-mm@kvack.org>; Sun,  6 Mar 2011 21:04:02 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D69E45DE51
	for <linux-mm@kvack.org>; Sun,  6 Mar 2011 21:04:02 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 22C1245DE4F
	for <linux-mm@kvack.org>; Sun,  6 Mar 2011 21:04:02 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 136DC1DB803B
	for <linux-mm@kvack.org>; Sun,  6 Mar 2011 21:04:02 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D52B11DB802F
	for <linux-mm@kvack.org>; Sun,  6 Mar 2011 21:04:01 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v4 0/4] exec: unify native/compat code
In-Reply-To: <20110305203040.GA7546@redhat.com>
References: <AANLkTimp=mhedXLdrZFqK2QWYvg7MdmUPj3-Q9m2vtTx@mail.gmail.com> <20110305203040.GA7546@redhat.com>
Message-Id: <20110306210334.6CD5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun,  6 Mar 2011 21:04:01 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, Milton Miller <miltonm@bga.com>, Linus Torvalds <torvalds@linux-foundation.org>

> On 03/03, Linus Torvalds wrote:
> >
> > On Thu, Mar 3, 2011 at 7:47 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> > >> I _personally_ don't like "conditional". Its name is based on code logic.
> > >> It's unclear what mean "conditional". From data strucuture view, It is
> > >> "opaque userland pointer".
> > >
> > > I agree with any naming, just suggest a better name ;)
> >
> > Maybe just "struct user_arg_ptr" or something?
> 
> OK, nothing else was suggessted, I assume Kosaki agrees.

Sure. :)

And, I happily reported this series run successfully my testsuite.
Could you please add my tested-by tag?

thanks.


> 
> So rename conditional_ptr to user_arg_ptr.
> 
> Also rename get_user_ptr() to get_user_arg_ptr(). It was suggested to
> use the same "user_arg_ptr" for this helper too, but this is not
> grep-friendly. As for get_ in the name... Well, I can redo again ;)
> But this matches get_user() and this is all what this helper does.
> 
> Otherwise unchanged.
> 
> Oleg.
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
