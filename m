Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id A417E6B002C
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 02:25:58 -0500 (EST)
Received: by lagz14 with SMTP id z14so7893683lag.14
        for <linux-mm@kvack.org>; Mon, 05 Mar 2012 23:25:56 -0800 (PST)
Date: Tue, 6 Mar 2012 09:25:39 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [patch -vmevent/core] mm, vmevent: vmevent_fd is conditional on
 CONFIG_VMEVENT
In-Reply-To: <alpine.DEB.2.00.1203052301050.25090@chino.kir.corp.google.com>
Message-ID: <alpine.LFD.2.02.1203060925310.6280@tux.localdomain>
References: <alpine.DEB.2.00.1203052301050.25090@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org

On Mon, 5 Mar 2012, David Rientjes wrote:
> The vmevent_fd syscall is declared but not defined without CONFIG_VMEVENT, 
> so make it conditional to avoid the following link error:
> 
> 	arch/x86/built-in.o:(.rodata+0xdb0): undefined reference to `sys_vmevent_fd'
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  kernel/sys_ni.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
> --- a/kernel/sys_ni.c
> +++ b/kernel/sys_ni.c
> @@ -191,6 +191,7 @@ cond_syscall(compat_sys_timerfd_settime);
>  cond_syscall(compat_sys_timerfd_gettime);
>  cond_syscall(sys_eventfd);
>  cond_syscall(sys_eventfd2);
> +cond_syscall(sys_vmevent_fd);
>  
>  /* performance counters: */
>  cond_syscall(sys_perf_event_open);

Applied, thanks David!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
