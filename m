Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0D26F8D0039
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 16:29:31 -0500 (EST)
Date: Sat, 5 Mar 2011 22:20:51 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v4 3/4] exec: unify do_execve/compat_do_execve code
Message-ID: <20110305212051.GA9937@redhat.com>
References: <20110302162650.GA26810@redhat.com> <20110302162712.GB26810@redhat.com> <20110303114952.B94B.A69D9226@jp.fujitsu.com> <20110303154706.GA22560@redhat.com> <AANLkTimp=mhedXLdrZFqK2QWYvg7MdmUPj3-Q9m2vtTx@mail.gmail.com> <20110305203040.GA7546@redhat.com> <20110305203140.GD7546@redhat.com> <AANLkTi=mce6tzg=vwf45XUQoADA=YbP2QJ2_tpg=QgQE@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTi=mce6tzg=vwf45XUQoADA=YbP2QJ2_tpg=QgQE@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, Milton Miller <miltonm@bga.com>

On 03/05, Linus Torvalds wrote:
>
> Ok, everything looks fine to me.
>
> Except looking at this, I don't think this part:
>
> On Sat, Mar 5, 2011 at 12:31 PM, Oleg Nesterov <oleg@redhat.com> wrote:
> >
> >  struct user_arg_ptr {
> > -       const char __user *const __user *native;
> > +#ifdef CONFIG_COMPAT
> > +       bool is_compat;
> > +#endif
> > +       union {
> > +               const char __user *const __user *native;
> > +               compat_uptr_t __user *compat;
> > +       } ptr;
> >  };
>
> will necessarily even compile on an architecture that doesn't have any
> 'compat' support.

Aaaaaaaaaaaaaaaaaah, now this is a really good point.

> Do we even define 'compat_uptr_t' for that case? I don't think so.

Indeed, you are right.

What I was thinking about? I do not know.

> So I suspect you need two of those annoying #ifdef's.

please expect v5 tomorrow.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
