Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 002086B01AC
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 13:54:45 -0400 (EDT)
Date: Wed, 2 Jun 2010 19:53:25 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] oom: Make coredump interruptible
Message-ID: <20100602175325.GA16474@redhat.com>
References: <20100601093951.2430.A69D9226@jp.fujitsu.com> <20100601201843.GA20732@redhat.com> <20100602221805.F524.A69D9226@jp.fujitsu.com> <20100602154210.GA9622@redhat.com> <20100602172956.5A3E34A491@magilla.sf.frob.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100602172956.5A3E34A491@magilla.sf.frob.com>
Sender: owner-linux-mm@kvack.org
To: Roland McGrath <roland@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On 06/02, Roland McGrath wrote:
>
> Why not just test TIF_MEMDIE?

Because it is per-thread.

when select_bad_process() finds the task P to kill it can participate
in the core dump (sleep in exit_mm), but we should somehow inform the
thread which actually dumps the core: P->mm->core_state->dumper.

Well, we can use TIF_MEMDIE if we chose the right thread, I think.
But perhaps mm->flags |= MMF_OOM is better, it can have other user.
I dunno.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
