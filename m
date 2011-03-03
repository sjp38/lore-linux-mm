Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 314FA8D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 22:09:31 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 8B2DB3EE0BD
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 12:09:27 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E5F745DE55
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 12:09:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 53FBA45DE5C
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 12:09:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 46B1C1DB8046
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 12:09:27 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 13BECE38001
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 12:09:27 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v3 4/4] exec: document acct_arg_size()
In-Reply-To: <20110302162812.GE26810@redhat.com>
References: <20110302162650.GA26810@redhat.com> <20110302162812.GE26810@redhat.com>
Message-Id: <20110303120917.B954.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  3 Mar 2011 12:09:25 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, Milton Miller <miltonm@bga.com>

> Add the comment to explain acct_arg_size().
> 
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> ---
> 
>  fs/exec.c |    7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> --- 38/fs/exec.c~4_doc_acct_arg_size	2011-03-02 16:21:57.000000000 +0100
> +++ 38/fs/exec.c	2011-03-02 16:27:24.000000000 +0100
> @@ -164,7 +164,12 @@ out:
>  }
>  
>  #ifdef CONFIG_MMU
> -
> +/*
> + * The nascent bprm->mm is not visible until exec_mmap() but it can
> + * use a lot of memory, account these pages in current->mm temporary
> + * for oom_badness()->get_mm_rss(). Once exec succeeds or fails, we
> + * change the counter back via acct_arg_size(0).
> + */
>  static void acct_arg_size(struct linux_binprm *bprm, unsigned long pages)
>  {
>  	struct mm_struct *mm = current->mm;
> 

Yeah! Thank you very much to make proper and clear comment.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
