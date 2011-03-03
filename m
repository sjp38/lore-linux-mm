Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 068908D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 10:56:09 -0500 (EST)
Date: Thu, 3 Mar 2011 16:47:06 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v3 1/4] exec: introduce get_arg_ptr() helper
Message-ID: <20110303154706.GA22560@redhat.com>
References: <20110302162650.GA26810@redhat.com> <20110302162712.GB26810@redhat.com> <20110303114952.B94B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110303114952.B94B.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, Milton Miller <miltonm@bga.com>

On 03/03, KOSAKI Motohiro wrote:
>
> > +static const char __user *
> > +get_arg_ptr(const char __user * const __user *argv, int argc)
> > +{
>
> [argc, argv] is natural order to me than [argv, argc].

Yes... in fact, "argc" is misnamed here. It doesn't mean the number of
arguments, it is the index in the array. Perhaps this should be [argv, nr].

> and "get_" prefix are usually used for reference count incrementing
> function in linux. so, i _personally_ prefer to call "user_arg_ptr".

Agreed, the name is ugly. I'll rename and resend keeping your reviewed-by.

[2/4]
> I _personally_ don't like "conditional". Its name is based on code logic.
> It's unclear what mean "conditional". From data strucuture view, It is
> "opaque userland pointer".

I agree with any naming, just suggest a better name ;)

[3/4]
> > +     struct conditional_ptr argv = {
> > +             .is_compat = true, .ptr.compat = __argv,
> > +     };
>
> Please don't mind to compress a line.
>
>         struct conditional_ptr argv = {
>                 .is_compat = true,
>                 .ptr.compat = __argv,
>         };

OK, will do.

Thanks for review!

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
