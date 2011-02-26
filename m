Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 782B88D0039
	for <linux-mm@kvack.org>; Sat, 26 Feb 2011 13:58:53 -0500 (EST)
Date: Sat, 26 Feb 2011 18:44:08 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 3/5] exec: unify compat_do_execve() code
Message-ID: <20110226174408.GA17442@redhat.com>
References: <20101130200129.GG11905@redhat.com> <compat-not-unlikely@mdm.bga.com> <20101201182747.GB6143@redhat.com> <20110225175202.GA19059@redhat.com> <20110225175314.GD19059@redhat.com> <AANLkTik8epq5cx8n=k6ocMUfbg9kkUAZ8KL7ZiG4UuoU@mail.gmail.com> <20110226123731.GC4416@redhat.com> <AANLkTinFVCR_znYtyVuJcjFQq_fgMp+ozbSz54UKzvQ_@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTinFVCR_znYtyVuJcjFQq_fgMp+ozbSz54UKzvQ_@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, Milton Miller <miltonm@bga.com>

On 02/26, Linus Torvalds wrote:
>
> On Sat, Feb 26, 2011 at 4:37 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> >>
> > Otherwise, get_arg_ptr() should return conditional_user_ptr_t as well,
>
> No it shouldn't.

(Yes I am stupid, see the next email).

> and notice how it gets the types right, and it even has one line LESS
> than your version, exactly because it gets the types right and doesn't
> need that implied cast in your
>
>      compat_uptr_t *a = argv;
>
> (in fact, I think your version needs an _explicit_ cast in order to
> not get a warning: you can't just cast "void **" to something else).

Yes, and get_user(argv) in the !compat case doesn't look nice, I agree.

> See? The advantage of the union is that the types are correct, which
> means that the casts are unnecessary.

My point was, apart from the trivial get_arg_ptr() helper, nobody else
uses this argv/envp, so I thought it is OK to drop the type info and
use "void *".

But as I said, I won't insist. I'll redo/resend.

Thanks.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
