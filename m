Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1EC7E6B0071
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 16:42:02 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id o59KfxFh016094
	for <linux-mm@kvack.org>; Wed, 9 Jun 2010 13:41:59 -0700
Received: from pxi3 (pxi3.prod.google.com [10.243.27.3])
	by wpaz33.hot.corp.google.com with ESMTP id o59KffQI028025
	for <linux-mm@kvack.org>; Wed, 9 Jun 2010 13:41:59 -0700
Received: by pxi3 with SMTP id 3so2148102pxi.10
        for <linux-mm@kvack.org>; Wed, 09 Jun 2010 13:41:57 -0700 (PDT)
Date: Wed, 9 Jun 2010 13:41:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: Make coredump interruptible
In-Reply-To: <20100609195309.GA6899@redhat.com>
Message-ID: <alpine.DEB.2.00.1006091341040.3490@chino.kir.corp.google.com>
References: <20100602185812.4B5894A549@magilla.sf.frob.com> <20100602203827.GA29244@redhat.com> <20100604194635.72D3.A69D9226@jp.fujitsu.com> <20100604112721.GA12582@redhat.com> <20100609195309.GA6899@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Roland McGrath <roland@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 9 Jun 2010, Oleg Nesterov wrote:

> --- x/mm/oom_kill.c
> +++ x/mm/oom_kill.c
> @@ -414,6 +414,7 @@ static void __oom_kill_task(struct task_
>  	p->rt.time_slice = HZ;
>  	set_tsk_thread_flag(p, TIF_MEMDIE);
>  
> +	clear_bit(MMF_COREDUMP, &p->mm->flags);
>  	force_sig(SIGKILL, p);
>  }
>  

This requires task_lock(p).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
