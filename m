Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9EF508D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 22:01:23 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B3B4C3EE0B5
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 12:01:19 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9358F45DE61
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 12:01:19 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7367545DE5A
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 12:01:19 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 57C27E08001
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 12:01:19 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1ACB41DB8048
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 12:01:19 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v3 1/4] exec: introduce get_arg_ptr() helper
In-Reply-To: <20110302162712.GB26810@redhat.com>
References: <20110302162650.GA26810@redhat.com> <20110302162712.GB26810@redhat.com>
Message-Id: <20110303114952.B94B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  3 Mar 2011 12:01:18 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, Milton Miller <miltonm@bga.com>

Hi

Sorry for the long delay. now I'm getting stuck sucky paper work. ;-)
In short, I don't find any issue in this patch. So, I'll test it at
this weekend if linus haven't merged it yet.

A few small and cosmetic comments are below. but anyway I don't want
keep this up in the air.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



> Introduce get_arg_ptr() helper, convert count() and copy_strings()
> to use it.
> 
> No functional changes, preparation. This helper is trivial, it just
> reads the pointer from argv/envp user-space array.
> 
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> ---
> 
>  fs/exec.c |   36 +++++++++++++++++++++++++-----------
>  1 file changed, 25 insertions(+), 11 deletions(-)
> 
> --- 38/fs/exec.c~1_get_arg_ptr	2011-03-02 15:15:27.000000000 +0100
> +++ 38/fs/exec.c	2011-03-02 15:16:44.000000000 +0100
> @@ -395,6 +395,17 @@ err:
>  	return err;
>  }
>  
> +static const char __user *
> +get_arg_ptr(const char __user * const __user *argv, int argc)
> +{

[argc, argv] is natural order to me than [argv, argc].
and "get_" prefix are usually used for reference count incrementing
function in linux. so, i _personally_ prefer to call "user_arg_ptr".



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
