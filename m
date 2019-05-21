Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 811F3C04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 17:29:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0BA68217D9
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 17:29:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="P3iQ35Eu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0BA68217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 663DB6B0003; Tue, 21 May 2019 13:29:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6175F6B0006; Tue, 21 May 2019 13:29:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DCB36B0007; Tue, 21 May 2019 13:29:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 235276B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 13:29:27 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id r78so6369972oie.8
        for <linux-mm@kvack.org>; Tue, 21 May 2019 10:29:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=JZkH899cMft3NriqnFbluuuxiqVxw6v9M9zlhn9yN3w=;
        b=Fi93eQuRXICqTgVAeJKFq64X2vPvP0DNY2tEfq4BGqeJFJszTOMZhsUetQVSBJUEiN
         VKG0f2hTvwLSwVJmUYyQupwjGAucE3NliVU1IUnAL4xA3LldK8wjw2hsuOw6hjMCqnWF
         GcbGxrwf3Jw+3+V4RnG0GcD3mhPSok09ou8oHn+oUdQ3w1KD92OGO0sy0HS6ZPjcusPh
         mPfcr+eEggyoTkFpCpsvuD1B4jSZaeSrUwj8KNhIIK/X4Yn2ppHxpwKzzm123cZLidbU
         9ifqOgZG0v/tAO7ZcItqOgXwX1uaFKuX5Gic3ATJLiAaH5bCqrA85JRpobHWgryuIBsG
         RQmQ==
X-Gm-Message-State: APjAAAV5OexL34fAps3sXn5GxW0L+1vgYKvnJOSH4bA0oUR0eDsNUelq
	LEYEUvwUvm4lUK90woCpN5sz9Lma/uh5/YHzOlqq4r/7wTdqdGXb6DTTIDdXdbTDWqnMbHbp7Cy
	zdgCnDDX6izxgwK+1XPc+d/WpUKVBNHgeekz9h8D7Gvz3dTinR4H5yKqU6uGpDih/6g==
X-Received: by 2002:a9d:2c2a:: with SMTP id f39mr49031040otb.67.1558459766721;
        Tue, 21 May 2019 10:29:26 -0700 (PDT)
X-Received: by 2002:a9d:2c2a:: with SMTP id f39mr49030987otb.67.1558459765715;
        Tue, 21 May 2019 10:29:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558459765; cv=none;
        d=google.com; s=arc-20160816;
        b=bqvb38Wxy5WVo769njWL2hYSNNvJprWz0ZmnI98OXd2o+bo5RierVnpG9GJK9hIYzK
         V1CkcwoKVfmASFW9VCdn5u/KKB8Oew9Z1O3/HPWwIVLuNfGNKmdSPd+8dV4rOtMTVlCH
         b3y6nErRZzWK5e54x7Y7y3HAESeRIoqHs25R3UjiTOM/MOSSO9N+6niZYCxji194ivnR
         uvWVGG9O6Y0q3SxQpSfhagmwmRYttWUi7BxYTBvp001CWmKfHhTMWVvM2kcXuErplamW
         5EVg5G4l0jB4yL1plzNeu+JrMaXDIoY7v1miVDCmm+8fdqT1qIaCc7mGqyBVQZdVt3o6
         iUPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=JZkH899cMft3NriqnFbluuuxiqVxw6v9M9zlhn9yN3w=;
        b=lH+A2VXuhx8TnG15WGx4g3ozfYDDN9Jw20JyFzZmiYVDziujqOdPrdlgNHc8x4PJxX
         EmgQbW0nUKKTzk4L34DDXKS7Xu5JUYFGB3rOwhyryd0QVYRjFwYNH3/pZJ8/KmNg3sh5
         BSwyzpYBmPIMxWp8YdttgxwyDwFNVD/SCZ+FVxEzLxIZIhH9bT75KNx87+GIUJA45h4J
         GHoUd//+t7EyktiUUJC7N0W7+Orw3j6AISPn2c7PpWpKQTPO0J5Mkbun1zhIJgEDEVdm
         TA8En97erXpDLKOwY5GfD3PtFTHR7h2dvvd9SfD38rw0tQZqWcfdscGMWpzrQjk2Fkhx
         2lVg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=P3iQ35Eu;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c26sor10196874otr.58.2019.05.21.10.29.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 10:29:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=P3iQ35Eu;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=JZkH899cMft3NriqnFbluuuxiqVxw6v9M9zlhn9yN3w=;
        b=P3iQ35EuyfDtHooEdbjohs5k55fLCV1rJaFQ0fc7MAJfML3SX7cJXNSLVdsrupNHmi
         5lkq6BI8Sj/iWUxf9g/aWs/nQzQgkaNQMQ/PBQYsKA1XliMhZLc3GrT/WC07GFE3ZS9Z
         pzccjY3pwoby1nWpgp8ivqkTQK4mgmgBxQ5b+kUK1yp5QzU3M8DvL1bbfv248dQe28bO
         Unzn05XcJFkPBeHrKLhwr2XPtTaK1/KJKVbq9XAQCx9Y8+Fb6xha75yYehZDNMtqurCV
         l+ZHqGAynT8bRC6xUTFbte94zIE3m0YB2BfTulFVg3gHCLsDoMW/bsmMTSwRo9qo7mEx
         Bm1g==
X-Google-Smtp-Source: APXvYqw7HXUy4K0HaHYv0BxFhx7C+RZx2NQiSRIQ8doSLJTez4tAj8hTmHNjpf4YTBuotTX+eneqN5EINh71j4hhp6M=
X-Received: by 2002:a9d:7347:: with SMTP id l7mr19465404otk.183.1558459764806;
 Tue, 21 May 2019 10:29:24 -0700 (PDT)
MIME-Version: 1.0
References: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
 <CALCETrU221N6uPmdaj4bRDDsf+Oc5tEfPERuyV24wsYKHn+spA@mail.gmail.com>
 <9638a51c-4295-924f-1852-1783c7f3e82d@virtuozzo.com> <CAG48ez2BcVCwYGmAo4MwZ2crZ9f7=qKrORcN=fYz=K5xP2xfgQ@mail.gmail.com>
 <069c90d6-924b-fa97-90d7-7d74f8785d9b@virtuozzo.com>
In-Reply-To: <069c90d6-924b-fa97-90d7-7d74f8785d9b@virtuozzo.com>
From: Jann Horn <jannh@google.com>
Date: Tue, 21 May 2019 19:28:58 +0200
Message-ID: <CAG48ez31Kxukg7y4PU-+3RjsYZxEHfjvs2q0EFqxDM2KDcLUoA@mail.gmail.com>
Subject: Re: [PATCH v2 0/7] mm: process_vm_mmap() -- syscall for duplication a
 process mapping
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, 
	Keith Busch <keith.busch@intel.com>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	Alexander Duyck <alexander.h.duyck@linux.intel.com>, Weiny Ira <ira.weiny@intel.com>, 
	Andrey Konovalov <andreyknvl@google.com>, arunks@codeaurora.org, 
	Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@surriel.com>, 
	Kees Cook <keescook@chromium.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	Nicholas Piggin <npiggin@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, 
	Shakeel Butt <shakeelb@google.com>, Roman Gushchin <guro@fb.com>, 
	Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, 
	Jerome Glisse <jglisse@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, 
	daniel.m.jordan@oracle.com, Adam Borowski <kilobyte@angband.pl>, 
	Linux API <linux-api@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 7:04 PM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
> On 21.05.2019 19:20, Jann Horn wrote:
> > On Tue, May 21, 2019 at 5:52 PM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
> >> On 21.05.2019 17:43, Andy Lutomirski wrote:
> >>> On Mon, May 20, 2019 at 7:01 AM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
> >>>> New syscall, which allows to clone a remote process VMA
> >>>> into local process VM. The remote process's page table
> >>>> entries related to the VMA are cloned into local process's
> >>>> page table (in any desired address, which makes this different
> >>>> from that happens during fork()). Huge pages are handled
> >>>> appropriately.
> > [...]
> >>>> There are several problems with process_vm_writev() in this example:
> >>>>
> >>>> 1)it causes pagefault on remote process memory, and it forces
> >>>>   allocation of a new page (if was not preallocated);
> >>>
> >>> I don't see how your new syscall helps.  You're writing to remote
> >>> memory.  If that memory wasn't allocated, it's going to get allocated
> >>> regardless of whether you use a write-like interface or an mmap-like
> >>> interface.
> >>
> >> No, the talk is not about just another interface for copying memory.
> >> The talk is about borrowing of remote task's VMA and corresponding
> >> page table's content. Syscall allows to copy part of page table
> >> with preallocated pages from remote to local process. See here:
> >>
> >> [task1]                                                        [task2]
> >>
> >> buf = mmap(NULL, n * PAGE_SIZE, PROT_READ|PROT_WRITE,
> >>            MAP_PRIVATE|MAP_ANONYMOUS, ...);
> >>
> >> <task1 populates buf>
> >>
> >>                                                                buf = process_vm_mmap(pid_of_task1, addr, n * PAGE_SIZE, ...);
> >> munmap(buf);
> >>
> >>
> >> process_vm_mmap() copies PTEs related to memory of buf in task1 to task2
> >> just like in the way we do during fork syscall.
> >>
> >> There is no copying of buf memory content, unless COW happens. This is
> >> the principal difference to process_vm_writev(), which just allocates
> >> pages in remote VM.
> >>
> >>> Keep in mind that, on x86, just the hardware part of a
> >>> page fault is very slow -- populating the memory with a syscall
> >>> instead of a fault may well be faster.
> >>
> >> It is not as slow, as disk IO has. Just compare, what happens in case of anonymous
> >> pages related to buf of task1 are swapped:
> >>
> >> 1)process_vm_writev() reads them back into memory;
> >>
> >> 2)process_vm_mmap() just copies swap PTEs from task1 page table
> >>   to task2 page table.
> >>
> >> Also, for faster page faults one may use huge pages for the mappings.
> >> But really, it's funny to think about page faults, when there are
> >> disk IO problems I shown.
> > [...]
> >>> That only doubles the amount of memory if you let n
> >>> scale linearly with p, which seems unlikely.
> >>>
> >>>>
> >>>> 3)received data has no a chance to be properly swapped for
> >>>>   a long time.
> >>>
> >>> ...
> >>>
> >>>> a)kernel moves @buf pages into swap right after recv();
> >>>> b)process_vm_writev() reads the data back from swap to pages;
> >>>
> >>> If you're under that much memory pressure and thrashing that badly,
> >>> your performance is going to be awful no matter what you're doing.  If
> >>> you indeed observe this behavior under normal loads, then this seems
> >>> like a VM issue that should be addressed in its own right.
> >>
> >> I don't think so. Imagine: a container migrates from one node to another.
> >> The nodes are the same, say, every of them has 4GB of RAM.
> >>
> >> Before the migration, the container's tasks used 4GB of RAM and 8GB of swap.
> >> After the page server on the second node received the pages, we want these
> >> pages become swapped as soon as possible, and we don't want to read them from
> >> swap to pass a read consumer.
> >
> > But you don't have to copy that memory into the container's tasks all
> > at once, right? Can't you, every time you've received a few dozen
> > kilobytes of data or whatever, shove them into the target task? That
> > way you don't have problems with swap because the time before the data
> > has arrived in its final VMA is tiny.
>
> We try to maintain online migration with as small downtime as possible,
> and the container on source node is completely stopped at the very end.
> Memory of container tasks is copied in background without container
> completely stop, and _PAGE_SOFT_DIRTY is used to track dirty pages.
>
> Container may create any new processes during the migration, and these
> processes may contain any memory mappings.
>
> Imagine the situation. We migrate a big web server with a lot of processes,
> and some of children processes have the same COW mapping as parent has.
> In case of all memory dump is available at the moment of the grand parent
> web server process creation, we populate the mapping in parent, and all
> the children may inherit the mapping in case of they want after fork.
> COW works here. But in case of some processes are created before all memory
> is available on destination node, we can't do such the COW inheritance.
> This will be the reason, the memory consumed by container grows many
> times after the migration. So, the only solution is to create process
> tree after memory is available and all mappings are known.

But if one of the processes modifies the memory after you've started
migrating it to the new machine, that memory can't be CoW anymore
anyway, right? So it should work if you first do a first pass of
copying the memory and creating the process hierarchy, and then copy
more recent changes into the individual processes, breaking the CoW
for those pages, right?

> It's on of the examples. But believe me, there are a lot of another reasons,
> why process tree should be created only after all process tree is freezed,
> and no new tasks on source are possible. PGID and SSID inheritance, for
> example. All of this requires special order of tasks creation. In case of
> you try to restore process tree with correct namespaces and especial in
> case of many user namespaces in a container, you will just see like a hell
> will open before your eyes, and we never can think about this.

Could you elaborate on why that is so hellish?


> So, no, we can't create any task before the whole process tree is knows.
> Believe me, the reason is heavy and serious.
>
> Kirill
>

