Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C76CC46470
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 14:44:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4398C217F5
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 14:44:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="ggdw0BLY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4398C217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA9646B000C; Tue, 21 May 2019 10:44:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E80736B000D; Tue, 21 May 2019 10:44:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D95C06B000E; Tue, 21 May 2019 10:44:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A3CB06B000C
	for <linux-mm@kvack.org>; Tue, 21 May 2019 10:44:11 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id u7so12457582pfh.17
        for <linux-mm@kvack.org>; Tue, 21 May 2019 07:44:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=G2qXE7Lk1dbyVx3bPCaDhNyJu8a54hfgTzvlxsm1O4o=;
        b=kjjw87ftPa2EBkhz4LR2hxzoxvAqJpACwTn0WapnRIUWxwTx/RRqapakqMo21nsbdt
         TirZi5TOScgxytW0QQr2ivN1qNbrlZxvFa3DU5R8U+YH57PQqVUS60bB4bK0n63wrBi6
         XrAHlIjuQ/CKUtl83/dyHAE8rbxK+cflPyqPqw3uz7jFfitHm4a7YZItYlMaqPPzXX8M
         yWYetnXvaKfTXmaWNbpyHz7zIbCoQpfNCKX1hrP+pYIik7xcH+H/QlmyPv3m0fKqRRmf
         QUuBkSjTeL5Co0uJzMTJwNEgse7jqj/343pG7HCBqGQMmmXjXVIrcyQpflMhgkl5u885
         9WkA==
X-Gm-Message-State: APjAAAVNJSqsBvjH7iXChAMbBEaJQAKLLENUwGZj94h0tlnIGf7BK/X4
	+W51M7JpBOzj6I5iPY3q/4xxrfsgzbdkNxVcVxKjqM6JCDLHsZQ5jJkhAihABYEoubgUtgInzfY
	1mWH5EHUiv9q7Ju+esiu+JtoFqj4+Zk+4wcgTmgRRy/AS483vgLplUTBtyhqoviHMKw==
X-Received: by 2002:a62:e90b:: with SMTP id j11mr36072317pfh.88.1558449851112;
        Tue, 21 May 2019 07:44:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6bftMeNb856Ns/DSn9SJU1xWdTZL1zHPqvjkPDELTYJfY4bB6a8Ya5BjyjQERNmbYGRBa
X-Received: by 2002:a62:e90b:: with SMTP id j11mr36072202pfh.88.1558449850092;
        Tue, 21 May 2019 07:44:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558449850; cv=none;
        d=google.com; s=arc-20160816;
        b=ymPI8OqqaCzQa3h+b184W2W2lmu1uuBirX/jGsvxWw9+F3qHcmkC40lW+9pOlMYXsu
         eZ6ohM1oAApBDdLMGL9T/uHmpU4Rwk5s0zAJ9a0aXpnAHaPpdOhKS1WP8LbLNFCpVDW4
         oOSI5LbjqLRBdR0zF+T1YGaMLYgVZNzBY3UPthd6hEjlio26UpM7/T5xSlxAlpYLrJHP
         U5xd9nXphXZYFnb/EZO3LV8k0QHJG8gHE9PpkiTiUFZqIkb9RUHhDhbQQnqKbmsei3F0
         L9nViR/S29dBHDar/LVvvh9WjJQthFf4gZ0yMjf53B8F93UCjX+nv/gA4I3DMWc1chqa
         V17Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=G2qXE7Lk1dbyVx3bPCaDhNyJu8a54hfgTzvlxsm1O4o=;
        b=btW6HUX4suZHTDmOVpHCXiJSePtnx3gPL6QzpfUWyJKG4Yb8JCIXHWK6ZykrJN1xd+
         Yzm3rMNL36M+wBp4yVAeDC7Z1AGaDKiqXeQh6KyuUTv7TwEqt2nXq+Gv2uWmxdXJz7TP
         yzGWC6O8dqW7JzoIWH4jPNjVR5uuxussKdBO8LtQGEb2az38jVaXR7+9p2w0XtEDiXYB
         1TK0TPUq3skqyYTMrScfWLwb55a75gtwYtwn0lSBI+fhJ8ejmN8l/iuieZT72hCnXwzX
         NUdWh0nkrcOAMrfvIEKfHyWuxy5SAORvVaDDj8TPtaNf59WFNKfGCFEjhiWItJoXZLQ8
         HPWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ggdw0BLY;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g17si3596299pgk.500.2019.05.21.07.44.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 07:44:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ggdw0BLY;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f54.google.com (mail-wm1-f54.google.com [209.85.128.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7F4A92186A
	for <linux-mm@kvack.org>; Tue, 21 May 2019 14:44:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558449849;
	bh=UXFXrEA/XzWJSiUo9Qp4UMS3ywgS7m/ucbmbFiKpKdg=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=ggdw0BLYs+MUWCzaemnKs7kSn7TwV/Z1WyTZ21WH/Jz1MnoGDQXLI9sEuswTUvuTS
	 8pQ9c8rrHOkToDiNw4MOcaMc2FDInI4T5EHyUjCtb3CIFqXtP49Sw4Q953xH/Y7U+O
	 DkHtReRVA2CdJGsCfXC19OMfPrqWV+XYmG7ky4Kc=
Received: by mail-wm1-f54.google.com with SMTP id 15so3175897wmg.5
        for <linux-mm@kvack.org>; Tue, 21 May 2019 07:44:09 -0700 (PDT)
X-Received: by 2002:a1c:e906:: with SMTP id q6mr3923719wmc.47.1558449846202;
 Tue, 21 May 2019 07:44:06 -0700 (PDT)
MIME-Version: 1.0
References: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
In-Reply-To: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 21 May 2019 07:43:54 -0700
X-Gmail-Original-Message-ID: <CALCETrU221N6uPmdaj4bRDDsf+Oc5tEfPERuyV24wsYKHn+spA@mail.gmail.com>
Message-ID: <CALCETrU221N6uPmdaj4bRDDsf+Oc5tEfPERuyV24wsYKHn+spA@mail.gmail.com>
Subject: Re: [PATCH v2 0/7] mm: process_vm_mmap() -- syscall for duplication a
 process mapping
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, 
	Michal Hocko <mhocko@suse.com>, Keith Busch <keith.busch@intel.com>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, alexander.h.duyck@linux.intel.com, 
	Weiny Ira <ira.weiny@intel.com>, Andrey Konovalov <andreyknvl@google.com>, arunks@codeaurora.org, 
	Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@surriel.com>, 
	Kees Cook <keescook@chromium.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	Nicholas Piggin <npiggin@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, 
	Shakeel Butt <shakeelb@google.com>, Roman Gushchin <guro@fb.com>, 
	Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, 
	Jerome Glisse <jglisse@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, 
	daniel.m.jordan@oracle.com, Jann Horn <jannh@google.com>, 
	Adam Borowski <kilobyte@angband.pl>, Linux API <linux-api@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 7:01 AM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>

> [Summary]
>
> New syscall, which allows to clone a remote process VMA
> into local process VM. The remote process's page table
> entries related to the VMA are cloned into local process's
> page table (in any desired address, which makes this different
> from that happens during fork()). Huge pages are handled
> appropriately.
>
> This allows to improve performance in significant way like
> it's shows in the example below.
>
> [Description]
>
> This patchset adds a new syscall, which makes possible
> to clone a VMA from a process to current process.
> The syscall supplements the functionality provided
> by process_vm_writev() and process_vm_readv() syscalls,
> and it may be useful in many situation.
>
> For example, it allows to make a zero copy of data,
> when process_vm_writev() was previously used:
>
>         struct iovec local_iov, remote_iov;
>         void *buf;
>
>         buf = mmap(NULL, n * PAGE_SIZE, PROT_READ|PROT_WRITE,
>                    MAP_PRIVATE|MAP_ANONYMOUS, ...);
>         recv(sock, buf, n * PAGE_SIZE, 0);
>
>         local_iov->iov_base = buf;
>         local_iov->iov_len = n * PAGE_SIZE;
>         remove_iov = ...;
>
>         process_vm_writev(pid, &local_iov, 1, &remote_iov, 1 0);
>         munmap(buf, n * PAGE_SIZE);
>
>         (Note, that above completely ignores error handling)
>
> There are several problems with process_vm_writev() in this example:
>
> 1)it causes pagefault on remote process memory, and it forces
>   allocation of a new page (if was not preallocated);

I don't see how your new syscall helps.  You're writing to remote
memory.  If that memory wasn't allocated, it's going to get allocated
regardless of whether you use a write-like interface or an mmap-like
interface.  Keep in mind that, on x86, just the hardware part of a
page fault is very slow -- populating the memory with a syscall
instead of a fault may well be faster.

>
> 2)amount of memory for this example is doubled in a moment --
>   n pages in current and n pages in remote tasks are occupied
>   at the same time;

This seems disingenuous.  If you're writing p pages total in chunks of
n pages, you will use a total of p pages if you use mmap and p+n if
you use write.  That only doubles the amount of memory if you let n
scale linearly with p, which seems unlikely.

>
> 3)received data has no a chance to be properly swapped for
>   a long time.

...

> a)kernel moves @buf pages into swap right after recv();
> b)process_vm_writev() reads the data back from swap to pages;

If you're under that much memory pressure and thrashing that badly,
your performance is going to be awful no matter what you're doing.  If
you indeed observe this behavior under normal loads, then this seems
like a VM issue that should be addressed in its own right.

>         buf = mmap(NULL, n * PAGE_SIZE, PROT_READ|PROT_WRITE,
>                    MAP_PRIVATE|MAP_ANONYMOUS, ...);
>         recv(sock, buf, n * PAGE_SIZE, 0);
>
> [Task 2]
>         buf2 = process_vm_mmap(pid_of_task1, buf, n * PAGE_SIZE, NULL, 0);
>
> This creates a copy of VMA related to buf from task1 in task2's VM.
> Task1's page table entries are copied into corresponding page table
> entries of VM of task2.

You need to fully explain a whole bunch of details that you're
ignored.  For example, if the remote VMA is MAP_ANONYMOUS, do you get
a CoW copy of it?  I assume you don't since the whole point is to
write to remote memory, but it's at the very least quite unusual in
Linux to have two different anonymous VMAs such that writing one of
them changes the other one.  But there are plenty of other questions.
What happens if the remote VMA is a gate area or other special mapping
(vDSO, vvar area, etc)?  What if the remote memory comes from a driver
that wasn't expecting the mapping to get magically copied to a
different process?

This new API seems quite dangerous and complex to me, and I don't
think the value has been adequately demonstrated.

