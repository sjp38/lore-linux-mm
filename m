Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9472B6B0012
	for <linux-mm@kvack.org>; Wed, 11 May 2011 19:33:55 -0400 (EDT)
Received: by qyk30 with SMTP id 30so749926qyk.14
        for <linux-mm@kvack.org>; Wed, 11 May 2011 16:33:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110510171641.16AF.A69D9226@jp.fujitsu.com>
References: <20110509182110.167F.A69D9226@jp.fujitsu.com>
	<20110510171335.16A7.A69D9226@jp.fujitsu.com>
	<20110510171641.16AF.A69D9226@jp.fujitsu.com>
Date: Thu, 12 May 2011 08:33:47 +0900
Message-ID: <BANLkTikcLk_Wbh47eYNh-_ETe3n4XXrDaw@mail.gmail.com>
Subject: Re: [PATCH 2/4] oom: kill younger process first
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: CAI Qian <caiqian@redhat.com>, avagin@gmail.com, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>

On Tue, May 10, 2011 at 5:15 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> This patch introduces do_each_thread_reverse() and
> select_bad_process() uses it. The benefits are two,
> 1) oom-killer can kill younger process than older if
> they have a same oom score. Usually younger process
> is less important. 2) younger task often have PF_EXITING
> because shell script makes a lot of short lived processes.
> Reverse order search can detect it faster.
>
> Reported-by: CAI Qian <caiqian@redhat.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
