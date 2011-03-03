Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 69BBF8D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 22:08:26 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id CCED33EE0B5
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 12:08:22 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B341645DE5B
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 12:08:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9ACCB45DE56
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 12:08:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D05BE08002
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 12:08:22 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2911D1DB8046
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 12:08:22 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v3 2/4] exec: introduce struct conditional_ptr
In-Reply-To: <20110302162732.GC26810@redhat.com>
References: <20110302162650.GA26810@redhat.com> <20110302162732.GC26810@redhat.com>
Message-Id: <20110303120211.B94E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  3 Mar 2011 12:08:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, Milton Miller <miltonm@bga.com>

> No functional changes, preparation.
> 
> Introduce struct conditional_ptr, change do_execve() paths to use it
> instead of "char __user * const __user *argv".
> 
> This makes the argv/envp arguments opaque, we are ready to handle the
> compat case which needs argv pointing to compat_uptr_t.
> 
> Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> ---
> 
>  fs/exec.c |   42 ++++++++++++++++++++++++++++++------------
>  1 file changed, 30 insertions(+), 12 deletions(-)
> 
> --- 38/fs/exec.c~2_typedef_for_argv	2011-03-02 15:40:22.000000000 +0100
> +++ 38/fs/exec.c	2011-03-02 15:40:44.000000000 +0100
> @@ -395,12 +395,15 @@ err:
>  	return err;
>  }
>  
> -static const char __user *
> -get_arg_ptr(const char __user * const __user *argv, int argc)
> +struct conditional_ptr {

I _personally_ don't like "conditional". Its name is based on code logic.
It's unclear what mean "conditional". From data strucuture view, It is 
"opaque userland pointer".

but again, it is my personal preference.

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
