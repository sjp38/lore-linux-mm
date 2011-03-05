Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E0ED08D0039
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 15:39:23 -0500 (EST)
Date: Sat, 5 Mar 2011 21:30:40 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH v4 0/4] exec: unify native/compat code
Message-ID: <20110305203040.GA7546@redhat.com>
References: <20110302162650.GA26810@redhat.com> <20110302162712.GB26810@redhat.com> <20110303114952.B94B.A69D9226@jp.fujitsu.com> <20110303154706.GA22560@redhat.com> <AANLkTimp=mhedXLdrZFqK2QWYvg7MdmUPj3-Q9m2vtTx@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTimp=mhedXLdrZFqK2QWYvg7MdmUPj3-Q9m2vtTx@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, Milton Miller <miltonm@bga.com>, Linus Torvalds <torvalds@linux-foundation.org>

On 03/03, Linus Torvalds wrote:
>
> On Thu, Mar 3, 2011 at 7:47 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> >> I _personally_ don't like "conditional". Its name is based on code logic.
> >> It's unclear what mean "conditional". From data strucuture view, It is
> >> "opaque userland pointer".
> >
> > I agree with any naming, just suggest a better name ;)
>
> Maybe just "struct user_arg_ptr" or something?

OK, nothing else was suggessted, I assume Kosaki agrees.

So rename conditional_ptr to user_arg_ptr.

Also rename get_user_ptr() to get_user_arg_ptr(). It was suggested to
use the same "user_arg_ptr" for this helper too, but this is not
grep-friendly. As for get_ in the name... Well, I can redo again ;)
But this matches get_user() and this is all what this helper does.

Otherwise unchanged.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
