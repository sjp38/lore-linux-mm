Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49539C04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 16:20:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E61D217D8
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 16:20:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="BIsbOTpu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E61D217D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F3D16B0006; Tue, 21 May 2019 12:20:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A3B56B0008; Tue, 21 May 2019 12:20:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 86BBB6B000A; Tue, 21 May 2019 12:20:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5E5236B0006
	for <linux-mm@kvack.org>; Tue, 21 May 2019 12:20:44 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id f18so9875386otf.22
        for <linux-mm@kvack.org>; Tue, 21 May 2019 09:20:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=BW3bQNoDviAamFC+RcRIIS02hInnMbbXec0nwAshfyk=;
        b=aWgZ8gyLDlXpguaJSgyOO5qLvZpWM5PAoh3b5JffVkHMV/AXG+XMT4ciyoNCo6TQJ0
         oxtd9BUpvUr+OOh0HesnMEJerCGshwcBZink16jQyNpLrwdyERgg1mqW+qV4PjVcAY3a
         cn+Ka3dD84Pcdmz/DwrttcZOAD+TTT7QQ6WPreHNmCDhq/9MqwlrPX1qTce/1x529Btl
         /GcMoYPInA/mCJlQVCGxrJmA9DsOV6D7egD0uD7Q1rNEg6pvCDkwX3vo4WVkQw/PtPNj
         dQWAkyvrMBevYNL6lslwh/zuxLyBSOdjl/r0RCiug7Ypw8zmkgvHQcRyYiNJl4A2XRQa
         YXvA==
X-Gm-Message-State: APjAAAVPmykXFt44rNE0KIRHcsaQKw5mzJ0pSILp+QRmpiTyo2JWhvPn
	yjTZ7lDrMbAORsA0wR9qCmqWBKds1PPaGzlCixs0M8qp0es3Na4sUBY+T9TPx322Jrvxi3NpKB+
	1oy4fUl5TlUfuhQAgOuLV9JP1fGE33a/94BkNiW+tBN0WVHH8TCkSD5Mizr9aUi1r7A==
X-Received: by 2002:aca:f303:: with SMTP id r3mr3704543oih.111.1558455643984;
        Tue, 21 May 2019 09:20:43 -0700 (PDT)
X-Received: by 2002:aca:f303:: with SMTP id r3mr3704508oih.111.1558455643284;
        Tue, 21 May 2019 09:20:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558455643; cv=none;
        d=google.com; s=arc-20160816;
        b=ZzuG6qWBqRvF4HLp1TXXvVu0g5h0QqJdiA4LjWHU74Zp+0hpgesendS6PtrXMn/lqj
         03ZbfoU28Lj1PlFCVxlgsIqaveuSDQT+PSz9cvITa47NyAD1HikA4RmUeAq94fGJfg8w
         7FDcNMIj7i7KzkEB+dS8t5FYL0EUt/eMC97n9W9OKF5iXwp5aKuMYI0VBsm76fOzufvG
         kCiBQ5R6Tfutaj6Cs9X1wUKjLJ4dMfRzk16YqjQ72YMYEJ5CmhHibgQnpmZY63fNHPEZ
         TpuhZFU2x2N8yI/XDyqNosvimHWjeHj4/Tc//yqsRvZlwFzD4Li00f2hbG4Z6gQQ8oky
         FJ9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=BW3bQNoDviAamFC+RcRIIS02hInnMbbXec0nwAshfyk=;
        b=F9gKPTnT9fI4OE88j97awYaa7vo9mJ4Ap190K66frzoDlvdZ6BE5haIr8Pt2SZgIr5
         urZacxQQJkyla9A0GkiuNgAPc8SLkdVQlmvebGnmFtuU7O484l3mkPbo5u9o79dYp2NF
         jvqwy26E5P04QqlodbRLGHEMo29siUdYPry4sRZgbyYUqNW1v5od9ucmrDmhZ0WtmCNw
         3oe0Q/FKaD5LLtJfapD8gvUSA6QsQnBUokME3A7fpQUU/egWXjxMsO1fPVwMz+YU//m3
         YlLI0Sm9rC27WbbPIo47sFyXC5kX5kG24EIarIB4zikI4dZBVfCdyHyV/ZZ/h2BTwdcy
         3f/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BIsbOTpu;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q10sor10312600oth.148.2019.05.21.09.20.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 09:20:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BIsbOTpu;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=BW3bQNoDviAamFC+RcRIIS02hInnMbbXec0nwAshfyk=;
        b=BIsbOTpu8o1r4oR1eExX7HB2wuf7SF+K+1MHv2XnAvbhBJK94bjaX5xD3Wz00KmoNf
         O34+uTz4vJ6ALRoh77myvTmXrWYWdqo+HxwNwrLbQCMBmPdAin6qfsGIqtkCARvPA2N6
         YOltAYKFOJqAnUMjA+r4baJ5pwlRpjQxbG27SvDbEShhPUNuPwMTC6ttd6WH1js0k1VQ
         sWsDtK5uUOPUUxD18R5Ixsq3x+A5W3nSQ/xZrxdVfvLlKfdbl6oBBgOrdBipX5gL0o7T
         +QQjXpZXtRhp7swD84820UmczIkTD/SPRl8g02G3iC6olxH7wcg/yWVEkGkWfYpnUig5
         K7kQ==
X-Google-Smtp-Source: APXvYqxHnjO0O+EyjFF0Z4zORdD2l9Rk3gkQ77tzlptApyPkz1WpeDUvMdq02nYzFbXQN+tda0ZsRLQKk/6mLvObkI8=
X-Received: by 2002:a9d:7f8b:: with SMTP id t11mr38337otp.110.1558455642667;
 Tue, 21 May 2019 09:20:42 -0700 (PDT)
MIME-Version: 1.0
References: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
 <CALCETrU221N6uPmdaj4bRDDsf+Oc5tEfPERuyV24wsYKHn+spA@mail.gmail.com> <9638a51c-4295-924f-1852-1783c7f3e82d@virtuozzo.com>
In-Reply-To: <9638a51c-4295-924f-1852-1783c7f3e82d@virtuozzo.com>
From: Jann Horn <jannh@google.com>
Date: Tue, 21 May 2019 18:20:16 +0200
Message-ID: <CAG48ez2BcVCwYGmAo4MwZ2crZ9f7=qKrORcN=fYz=K5xP2xfgQ@mail.gmail.com>
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

On Tue, May 21, 2019 at 5:52 PM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
> On 21.05.2019 17:43, Andy Lutomirski wrote:
> > On Mon, May 20, 2019 at 7:01 AM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
> >> New syscall, which allows to clone a remote process VMA
> >> into local process VM. The remote process's page table
> >> entries related to the VMA are cloned into local process's
> >> page table (in any desired address, which makes this different
> >> from that happens during fork()). Huge pages are handled
> >> appropriately.
[...]
> >> There are several problems with process_vm_writev() in this example:
> >>
> >> 1)it causes pagefault on remote process memory, and it forces
> >>   allocation of a new page (if was not preallocated);
> >
> > I don't see how your new syscall helps.  You're writing to remote
> > memory.  If that memory wasn't allocated, it's going to get allocated
> > regardless of whether you use a write-like interface or an mmap-like
> > interface.
>
> No, the talk is not about just another interface for copying memory.
> The talk is about borrowing of remote task's VMA and corresponding
> page table's content. Syscall allows to copy part of page table
> with preallocated pages from remote to local process. See here:
>
> [task1]                                                        [task2]
>
> buf = mmap(NULL, n * PAGE_SIZE, PROT_READ|PROT_WRITE,
>            MAP_PRIVATE|MAP_ANONYMOUS, ...);
>
> <task1 populates buf>
>
>                                                                buf = process_vm_mmap(pid_of_task1, addr, n * PAGE_SIZE, ...);
> munmap(buf);
>
>
> process_vm_mmap() copies PTEs related to memory of buf in task1 to task2
> just like in the way we do during fork syscall.
>
> There is no copying of buf memory content, unless COW happens. This is
> the principal difference to process_vm_writev(), which just allocates
> pages in remote VM.
>
> > Keep in mind that, on x86, just the hardware part of a
> > page fault is very slow -- populating the memory with a syscall
> > instead of a fault may well be faster.
>
> It is not as slow, as disk IO has. Just compare, what happens in case of anonymous
> pages related to buf of task1 are swapped:
>
> 1)process_vm_writev() reads them back into memory;
>
> 2)process_vm_mmap() just copies swap PTEs from task1 page table
>   to task2 page table.
>
> Also, for faster page faults one may use huge pages for the mappings.
> But really, it's funny to think about page faults, when there are
> disk IO problems I shown.
[...]
> > That only doubles the amount of memory if you let n
> > scale linearly with p, which seems unlikely.
> >
> >>
> >> 3)received data has no a chance to be properly swapped for
> >>   a long time.
> >
> > ...
> >
> >> a)kernel moves @buf pages into swap right after recv();
> >> b)process_vm_writev() reads the data back from swap to pages;
> >
> > If you're under that much memory pressure and thrashing that badly,
> > your performance is going to be awful no matter what you're doing.  If
> > you indeed observe this behavior under normal loads, then this seems
> > like a VM issue that should be addressed in its own right.
>
> I don't think so. Imagine: a container migrates from one node to another.
> The nodes are the same, say, every of them has 4GB of RAM.
>
> Before the migration, the container's tasks used 4GB of RAM and 8GB of swap.
> After the page server on the second node received the pages, we want these
> pages become swapped as soon as possible, and we don't want to read them from
> swap to pass a read consumer.

But you don't have to copy that memory into the container's tasks all
at once, right? Can't you, every time you've received a few dozen
kilobytes of data or whatever, shove them into the target task? That
way you don't have problems with swap because the time before the data
has arrived in its final VMA is tiny.

