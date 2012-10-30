Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id BAF8C6B0068
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 01:41:57 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so4304961pad.14
        for <linux-mm@kvack.org>; Mon, 29 Oct 2012 22:41:56 -0700 (PDT)
Date: Mon, 29 Oct 2012 22:41:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: zram OOM behavior
In-Reply-To: <CAA25o9R0zgW74NRGyZZHy4cFbfuVEmHWVC=4O7SuUjywN+Uvpw@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1210292239290.13203@chino.kir.corp.google.com>
References: <20121015144412.GA2173@barrios> <CAA25o9R53oJajrzrWcLSAXcjAd45oQ4U+gJ3Mq=bthD3HGRaFA@mail.gmail.com> <20121016061854.GB3934@barrios> <CAA25o9R5OYSMZ=Rs2qy9rPk3U9yaGLLXVB60Yncqvmf3Y_Xbvg@mail.gmail.com> <CAA25o9QcaqMsYV-Z6zTyKdXXwtCHCAV_riYv+Bhtv2RW0niJHQ@mail.gmail.com>
 <20121022235321.GK13817@bbox> <alpine.DEB.2.00.1210222257580.22198@chino.kir.corp.google.com> <CAA25o9ScWUsRr2ziqiEt9U9UvuMuYim+tNpPCyN88Qr53uGhVQ@mail.gmail.com> <alpine.DEB.2.00.1210291158510.10845@chino.kir.corp.google.com>
 <CAA25o9Rk_C=jaHJwWQ8TJL0NF5_Xv2umwxirtdugF6w3rHruXg@mail.gmail.com> <20121030001809.GL15767@bbox> <CAA25o9R0zgW74NRGyZZHy4cFbfuVEmHWVC=4O7SuUjywN+Uvpw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Mon, 29 Oct 2012, Luigi Semenzato wrote:

> However, now there is something that worries me more.  The trace of
> the thread with TIF_MEMDIE set shows that it has executed most of
> do_exit() and appears to be waiting to be reaped.  From my reading of
> the code, this implies that task->exit_state should be non-zero, which
> means that select_bad_process should have skipped that thread, which
> means that we cannot be in the deadlock situation, and my experiments
> are not consistent.
> 

Yeah, this is what I was referring to earlier, select_bad_process() will 
not consider the thread for which you posted a stack trace for oom kill, 
so it's not deferring because of it.  There are either other thread(s) 
that have been oom killed and have not yet release their memory or the oom 
killer is never being called.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
