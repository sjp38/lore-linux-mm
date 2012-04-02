Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id A71946B0044
	for <linux-mm@kvack.org>; Mon,  2 Apr 2012 12:27:39 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so3165448bkw.14
        for <linux-mm@kvack.org>; Mon, 02 Apr 2012 09:27:37 -0700 (PDT)
Date: Mon, 2 Apr 2012 20:27:33 +0400
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: Re: [PATCH 6/7] mm: kill vma flag VM_EXECUTABLE
Message-ID: <20120402162733.GI7607@moon>
References: <20120331091049.19373.28994.stgit@zurg>
 <20120331092929.19920.54540.stgit@zurg>
 <20120331201324.GA17565@redhat.com>
 <20120331203912.GB687@moon>
 <4F79755B.3030703@openvz.org>
 <20120402144821.GA3334@redhat.com>
 <4F79D1AF.7080100@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F79D1AF.7080100@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>, Oleg Nesterov <oleg@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Eric Paris <eparis@redhat.com>

On Mon, Apr 02, 2012 at 08:19:59PM +0400, Konstantin Khlebnikov wrote:
> Oleg Nesterov wrote:
> >On 04/02, Konstantin Khlebnikov wrote:
> >>
> >>In this patch I leave mm->exe_file lockless.
> >>After exec/fork we can change it only for current task and only if mm->mm_users == 1.
> >>
> >>something like this:
> >>
> >>task_lock(current);
> >
> >OK, this protects against the race with get_task_mm()
> >
> >>if (atomic_read(&current->mm->mm_users) == 1)
> >
> >this means PR_SET_MM_EXE_FILE can fail simply because someone did
> >get_task_mm(). Or the caller is multithreaded.
> 
> This is sad, seems like we should keep mm->exe_file protection by mm->mmap_sem.
> So, I'll rework this patch...

Ah, it's about locking. I misundertand it at first.
Oleg, forget about my email then.

	Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
