Date: Sun, 10 Jun 2007 19:30:23 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH 14 of 16] oom select should only take rss into account
Message-ID: <20070610173022.GA7443@v2.random>
References: <dbd70ffd95f34cd12f1f.1181332992@v2.random> <466C3219.4040406@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <466C3219.4040406@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 10, 2007 at 01:17:13PM -0400, Rik van Riel wrote:
> Andrea Arcangeli wrote:
> 
> >diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> >--- a/mm/oom_kill.c
> >+++ b/mm/oom_kill.c
> >@@ -66,7 +66,7 @@ unsigned long badness(struct task_struct
> > 	/*
> > 	 * The memory size of the process is the basis for the badness.
> > 	 */
> >-	points = mm->total_vm;
> >+	points = get_mm_rss(mm);
> 
> Makes sense.  Originally it used total_vm so it could also
> select tasks that use up lots of swap, but I guess that in
> almost all the cases the preferred OOM task to kill is also
> using a lot of RAM.

Agreed.

> Acked-by: Rik van Riel <riel@redhat.com>

Thanks for the Ack.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
