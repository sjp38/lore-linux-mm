Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A9C926B005A
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 20:40:17 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id n8G0eI8Z022273
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 17:40:19 -0700
Received: from pzk1 (pzk1.prod.google.com [10.243.19.129])
	by wpaz1.hot.corp.google.com with ESMTP id n8G0e4Lx017979
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 17:40:16 -0700
Received: by pzk1 with SMTP id 1so1343183pzk.13
        for <linux-mm@kvack.org>; Tue, 15 Sep 2009 17:40:16 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 15 Sep 2009 17:40:15 -0700
Message-ID: <6599ad830909151740n2affe0daw27618ccae9c737d6@mail.gmail.com>
Subject: Re: 2.6.32 -mm merge plans (cgroups)
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 15, 2009 at 4:15 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> cgroups-make-unlock-sequence-in-cgroup_get_sb-consistent.patch
> cgroups-support-named-cgroups-hierarchies.patch
> cgroups-move-the-cgroup-debug-subsys-into-cgroupc-to-access-internal-state.patch
> cgroups-add-a-back-pointer-from-struct-cg_cgroup_link-to-struct-cgroup.patch
> cgroups-allow-cgroup-hierarchies-to-be-created-with-no-bound-subsystems.patch

I think these first five should be fine for merge.

> cgroups-revert-cgroups-fix-pid-namespace-bug.patch
> cgroups-add-a-read-only-procs-file-similar-to-tasks-that-shows-only-unique-tgids.patch
> cgroups-ensure-correct-concurrent-opening-reading-of-pidlists-across-pid-namespaces.patch
> cgroups-use-vmalloc-for-large-cgroups-pidlist-allocations.patch
> cgroups-change-css_set-freeing-mechanism-to-be-under-rcu.patch
> cgroups-let-ss-can_attach-and-ss-attach-do-whole-threadgroups-at-a-time.patch
> cgroups-let-ss-can_attach-and-ss-attach-do-whole-threadgroups-at-a-time-fix.patch
> #cgroups-add-functionality-to-read-write-lock-clone_thread-forking-per-threadgroup.patch: Oleg conniptions
> cgroups-add-functionality-to-read-write-lock-clone_thread-forking-per-threadgroup.patch
> cgroups-add-functionality-to-read-write-lock-clone_thread-forking-per-threadgroup-fix.patch
> cgroups-add-ability-to-move-all-threads-in-a-process-to-a-new-cgroup-atomically.patch

How much longer is the merge window open for? It's probably safest to
hold these in -mm for now since we've not resolved the potential races
in the signal handler accesses; I'll try to find some time to work on
them this week or next.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
