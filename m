Date: Thu, 25 Mar 2004 10:35:06 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.5-rc2-mm3 blizzard of "bad: scheduling while atomic" with
 PREEMPT
Message-Id: <20040325103506.19129deb.akpm@osdl.org>
In-Reply-To: <1080237733.2269.31.camel@spc0.esa.lanl.gov>
References: <1080237733.2269.31.camel@spc0.esa.lanl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Cole <elenstev@mesatop.com>
Cc: linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

Steven Cole <elenstev@mesatop.com> wrote:
>
> Apologies in advance if this is a known problem.  I looked through
>  some recent archives and didn't find this exact situation, so here it
>  is.  I'm just starting to test the -mm kernels again after a pause,
>  so I'm not up on the current problem set.
> 
>  Kernel is 2.6.5-rc2-mm3 with SMP and PREEMPT.  Box is dual PIII.
>  Base distro is Mandrake 10.
> 
>  These messages were the start of about 8,000 lines of similar.
>  The "while atomic" message came out about 374 times before it
>  seemed to stop.
> 
>  Recompiling without PREEMPT made this go away.

err, yes.  Ingo broke it ;)

bad: scheduling while atomic!
Call Trace:
 [<c011d0f0>] schedule+0x3c/0x58c
 [<c0109f69>] dump_stack+0x19/0x20
 [<c011f146>] __might_sleep+0xaa/0xb4
 [<c011d91a>] wait_for_completion+0xae/0x110
 [<c011d688>] default_wake_function+0x0/0x1c
 [<c011d688>] default_wake_function+0x0/0x1c
 [<c011be8b>] sched_migrate_task+0x6b/0x9c
 [<c011c023>] sched_balance_exec+0x63/0x8c
 [<c0167108>] do_execve+0x14/0x200
 [<c0141ef5>] buffered_rmqueue+0x1c5/0x1d4
 [<c0141fae>] __alloc_pages+0xaa/0x2fc
 [<c014c5c2>] do_wp_page+0x3c2/0x478
 [<c014d6c3>] handle_mm_fault+0x107/0x174
 [<c01196b5>] do_page_fault+0x15d/0x4ba
 [<c0119558>] do_page_fault+0x0/0x4ba
 [<c02865b6>] tiocspgrp+0x72/0x9c
 [<c012aca9>] recalc_sigpending+0x11/0x18
 [<c0168a6f>] getname+0x5f/0xa0
 [<c0107a6f>] sys_execve+0x2f/0x68
 [<c0109185>] sysenter_past_esp+0x52/0x71

Fortunately vger seems to have gobbled the mm3 announcement.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
