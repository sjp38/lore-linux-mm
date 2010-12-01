Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A7A406B009F
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 13:14:34 -0500 (EST)
Date: Wed, 1 Dec 2010 19:07:53 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 1/2] exec: make argv/envp memory visible to oom-killer
Message-ID: <20101201180753.GA6143@redhat.com>
References: <20101130195456.GA11905@redhat.com> <20101130195534.GB11905@redhat.com> <20101201090350.ABA2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101201090350.ABA2.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On 12/01, KOSAKI Motohiro wrote:
>
> > +static void acct_arg_size(struct linux_binprm *bprm, unsigned long pages)
>
> One minor request.
>
> I guess this function can easily makes confusing to a code reader. So I
> hope you write small function comments. describe to
>  - What is oom nascent issue
>  - Why we think inaccurate account is ok

Agreed, this needs a comment.

The patch was already applied, I'll send a separate one on top
of the next "unify exec/compat" series. Or, I'll add the comments
into this series, depending on review.

Thanks,

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
